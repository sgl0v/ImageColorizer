//
//  DispatchQueue+Utils.swift
//  Coloriser-CoreML
//
//  Created by Maksym Shcheglov on 20/10/2020.
//  Copyright © 2020 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension DispatchQueue {

    static var background = DispatchQueue(label: "com.sgl0v.colorizer", qos: .userInitiated)

}
