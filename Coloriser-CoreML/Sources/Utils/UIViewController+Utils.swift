//
//  UIViewController+Utils.swift
//  Coloriser-CoreML
//
//  Created by Maksym Shcheglov on 18/10/2020.
//  Copyright © 2020 Maksym Shcheglov. All rights reserved.
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

