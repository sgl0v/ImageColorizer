//
//  ImagePicker.swift
//  Coloriser-CoreML
//
//  Created by Maksym Shcheglov on 21/10/2020.
//  Copyright © 2020 Maksym Shcheglov. All rights reserved.
//

import UIKit
import PhotosUI

final class ImagePicker: ImageProvider {
    private var completion: Completion?

    func image(with completion: @escaping Completion) {
        guard self.completion == nil else {
            completion(.failure(ImageProviderError.startFailure))
            return
        }
        self.completion = completion

        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        UIViewController.topmostViewContoller.present(picker, animated: true)
    }
}

extension ImagePicker: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let itemProvider = results.first?.itemProvider else {
            self.completion = nil
            picker.dismiss(animated: true)
            return
        }
        image(from: itemProvider) { result in
            self.completion?(result)
            self.completion = nil
            picker.dismiss(animated: true)
        }
    }

    private func image(from itemProvider: NSItemProvider, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
            completion(.failure(ImageProviderError.internalError))
            return
        }

        itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async { completion(.success(image)) }
            } else {
                DispatchQueue.main.async { completion(.failure(ImageProviderError.internalError)) }
            }
        }
    }
}
