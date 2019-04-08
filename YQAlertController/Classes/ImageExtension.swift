//
//  ImageExtension.swift
//  YQAlertController
//
//  Created by 王叶庆 on 2019/4/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class YQAlertControllerIdentifierImage: UIImage {
    
}

extension UIImage {
    static let bundle = Bundle(for: YQAlertControllerIdentifierImage.classForCoder())
    static func named(_ name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle(path: bundle.bundlePath + "/YQAlertController.bundle"), compatibleWith: nil)
    }
}

