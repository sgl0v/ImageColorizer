//
//  ImageColoriser
//
//  Created by Maksym Shcheglov.
//  Copyright © 2021 Maksym Shcheglov. All rights reserved.
//

import UIKit

enum ImageProviderError: Error {
    case startFailure, internalError
}

protocol ImageProvider {
    typealias Completion = (Result<UIImage, Error>) -> Void
    func image(with completion: @escaping Completion)
}
