//
//  ImageScanner.swift
//  Coloriser-CoreML
//
//  Created by Maksym Shcheglov on 18/10/2020.
//  Copyright © 2020 Maksym Shcheglov. All rights reserved.
//

import UIKit
import Vision

final class ImageScanner: NSObject, ImageProvider {
    private var completion: Completion?

    func image(with completion: @escaping Completion) {
        guard self.completion == nil, UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(.failure(ImageProviderError.startFailure))
            return
        }
        self.completion = completion

        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        UIViewController.topmostViewContoller.present(pickerController, animated: true)
    }
}

extension ImageScanner: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            dismissController(picker, with: .failure(ImageProviderError.internalError))
            return
        }

        DispatchQueue.background.async {
            let result = self.postProcessImage(uiImage)
            self.dismissController(picker, with: result)
        }
    }

    private func postProcessImage(_ image: UIImage) -> Result<UIImage, Error> {
        guard let ciImage = CIImage(image: image),
              let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else {
            return .failure(ImageProviderError.internalError)
        }
        let inputImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))
        return detectRectangle(on: ciImage, orientation: orientation).flatMap {detectedRectangle in
            self.cropImage(inputImage, with: detectedRectangle)
        }
    }

    private func detectRectangle(on image: CIImage, orientation: CGImagePropertyOrientation) -> Result<VNRectangleObservation, Error> {
        var result: Result<VNRectangleObservation, Error> = .failure(ImageProviderError.internalError)
        let semaphore = DispatchSemaphore(value: 1)
        let rectanglesRequest = VNDetectRectanglesRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRectangleObservation],
                  let detectedRectangle = observations.first else {
                return
            }
            result = .success(detectedRectangle)
            semaphore.signal()
        }
        let handler = VNImageRequestHandler(ciImage: image, orientation: orientation)
        if (try? handler.perform([rectanglesRequest])) != nil { semaphore.wait() }
        return result
    }

    private func cropImage(_ inputImage: CIImage, with detectedRectangle: VNRectangleObservation) -> Result<UIImage, Error> {
        let imageSize = inputImage.extent.size
        let transform = CGAffineTransform.identity.scaledBy(x: imageSize.width, y: imageSize.height)
        let boundingBox = detectedRectangle.boundingBox.applying(transform)
        guard inputImage.extent.contains(boundingBox) else {
            return .failure(ImageProviderError.internalError)
        }

        let topLeft = detectedRectangle.topLeft.applying(transform)
        let topRight = detectedRectangle.topRight.applying(transform)
        let bottomLeft = detectedRectangle.bottomLeft.applying(transform)
        let bottomRight = detectedRectangle.bottomRight.applying(transform)
        let correctedImage = inputImage.cropped(to: boundingBox)
            .applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
            .transformed(by: CGAffineTransform.identity.rotated(by: 90 / 180.0 * CGFloat.pi))

        let imageRef = CIContext().createCGImage(correctedImage, from: correctedImage.extent)!
        return .success(UIImage(cgImage: imageRef))
    }

    private func dismissController(_ controller: UIViewController, with result: Result<UIImage, Error>) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.completion?(result)
                self.completion = nil
            }
        }
    }
}
