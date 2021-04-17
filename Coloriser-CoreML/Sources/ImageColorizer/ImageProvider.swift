//
//  ImageProvider.swift
//  Coloriser-CoreML
//
//  Created by Maksym Shcheglov on 21/10/2020.
//  Copyright © 2020 Maksym Shcheglov. All rights reserved.
//

import UIKit

enum ImageProviderError: Error {
    case startFailure, internalError
}

protocol ImageProvider {
    typealias Completion = (Result<UIImage, Error>) -> Void
    func image(with completion: @escaping Completion)
}
