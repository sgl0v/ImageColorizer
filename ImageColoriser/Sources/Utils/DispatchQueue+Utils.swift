//
//  ImageColoriser
//
//  Created by Maksym Shcheglov.
//  Copyright © 2021 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension DispatchQueue {

    static var background = DispatchQueue(label: "com.sgl0v.colorizer", qos: .userInitiated)

}
