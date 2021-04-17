//
//  ViewController.swift
//  Coloriser-CoreML
//
//  Created by Maksym Shcheglov on 31/01/2020.
//  Copyright © 2020 Maksym Shcheglov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    enum State {
        case idle
        case loading
        case success(UIImage)
        case failure(Error)
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private let colorizer = ImageColorizer()
    private let scanner = ImageScanner()
    private let picker = ImagePicker()
    private var state: State = .idle {
        didSet {
            render(state)
        }
    }
    
    @IBAction func openImage(_ sender: Any) {
        selectImage { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                let scaledImage = image.scaled(with: self.imageView.bounds.width)
                self.colorize(scaledImage)
            case .failure(let error):
                self.showErrorAlert(error)
            }
        }
    }
}

// MARK: Private
extension ViewController {

    private func colorize(_ image: UIImage) {
        state = .loading
        colorizer.colorize(image: image) {[unowned self] result in
            self.state = self.createState(from: result)
        }
    }

    private func createState(from result: Result<UIImage, Error>) -> State {
        switch result {
        case .success(let image):
            return .success(image)
        case .failure(let error):
            return .failure(error)
        }
    }

    private func render(_ state: State) {
        switch state {
        case .idle:
            activityIndicator.isHidden = true
            imageView.image = nil
        case .loading:
            activityIndicator.isHidden = false
            imageView.image = nil
        case .failure(let error):
            activityIndicator.isHidden = true
            imageView.image = nil
            showErrorAlert(error)
        case .success(let image):
            activityIndicator.isHidden = true
            imageView.image = image
        }
    }

    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "Message", message: "Failed to colorize the image!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        UIViewController.topmostViewContoller.present(alert, animated: true)
    }

    private func selectImage(_ completion: @escaping ImageProvider.Completion) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photos", style: .default) { _ in
            self.picker.image(with: completion)
        })
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.scanner.image(with: completion)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        UIViewController.topmostViewContoller.present(alert, animated: true)
    }
}
