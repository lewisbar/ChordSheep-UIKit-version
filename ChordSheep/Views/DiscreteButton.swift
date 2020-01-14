//
//  DiscreteButton.swift
//  Choly
//
//  Created by Lennart Wisbar on 16.04.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class DiscreteButton: UIButton {
    
    convenience init(title: String, target: Any?, action: Selector) {
        self.init(type: .system)
        self.setTitle(title, for: .normal)
        self.addTarget(target, action: action, for: .touchUpInside)
        self.titleLabel?.textColor = .black
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
}
