//
//  DiscreteButton.swift
//  Choly
//
//  Created by Lennart Wisbar on 16.04.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

//class DiscreteButton: UIButton {
//    
//    convenience init(type: UIButton.ButtonType = UIButton.ButtonType.system, title: String? = nil, target: Any?, action: Selector) {
//        self.init(type: type)
//        if let title = title {
//            self.setTitle(title, for: .normal)
//        }
//        self.addTarget(target, action: action, for: .touchUpInside)
//        self.titleLabel?.textColor = .white
//        self.tintColor = .white
//        self.backgroundColor = .blueCharcoal // UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.layer.cornerRadius = self.bounds.size.height / 2
//    }
//}

extension UIButton {
    class func discreteButton(backgroundImage: UIImage, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(backgroundImage, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
}
