//
//  ImageColoriser
//
//  Created by Maksym Shcheglov.
//  Copyright © 2021 Maksym Shcheglov. All rights reserved.
//

import UIKit

extension UIViewController {

    static var topmostViewContoller: UIViewController {
        var topController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.rootViewController!
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}

