//
//  ButtonHeader.swift
//  Choly
//
//  Created by Lennart Wisbar on 21.03.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class ButtonHeader: UIStackView {
    
    convenience init(title: String, target: Any, selector: Selector) {
        self.init()
        setUpStackViewProperties()
        
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "Avenir-Heavy", size: 28)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.lineBreakMode = .byClipping
        self.addArrangedSubview(label)
        
        self.addArrangedSubview(button(withTarget: target, selector: selector))
        addBackground()
    }
    
    convenience init(titleView: UIView, target: Any, selector: Selector) {
        self.init()
        setUpStackViewProperties()
        self.addArrangedSubview(titleView)
        self.addArrangedSubview(button(withTarget: target, selector: selector))
        addBackground()
    }
    
    
    private func setUpStackViewProperties() {
        self.axis = .horizontal
        self.distribution = .fill
        self.layoutMargins = UIEdgeInsets(top: 20, left: 12, bottom: 0, right: 0)
        self.isLayoutMarginsRelativeArrangement = true
    }
    
    private func button(withTarget target: Any, selector: Selector) -> UIButton{
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.addTarget(target, action: selector, for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }
    
    private func addBackground() {
        // Adding a view to make the header opaque (because UIStackView is not rendered, so setting its color has no effect)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(backgroundView, at: 0)
    }
}


//extension UITableViewController {
//
//    func sectionHeaderView(withTitle title: String, addButtonWithTarget target: Any? = nil, selector: Selector? = nil, editable: Bool = false) -> UIView {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.distribution = .fill
//        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 12, bottom: 0, right: 0)
//        stackView.isLayoutMarginsRelativeArrangement = true
//
//        if editable {
//            let textField = UITextField()
//            textField.text = title
//            textField.font = UIFont(name: "Avenir-Heavy", size: 28)
//            textField.adjustsFontSizeToFitWidth = true
//            stackView.addArrangedSubview(textField)
//            textField.becomeFirstResponder()
//        } else {
//            let label = UILabel()
//            label.text = title
//            label.font = UIFont(name: "Avenir-Heavy", size: 28)
//            label.adjustsFontSizeToFitWidth = true
//            label.minimumScaleFactor = 0.7
//            label.lineBreakMode = .byClipping
//            stackView.addArrangedSubview(label)
//        }
//
//        if let selector = selector {
//            let button = UIButton(type: .system)
//            button.setTitle("+", for: .normal)
//            button.addTarget(target, action: selector, for: .touchUpInside)
//            button.setContentHuggingPriority(.required, for: .horizontal)
//            stackView.addArrangedSubview(button)
//        }
//
//        // Adding a view to make the header opaque (because UIStackView is not rendered, so setting its color has no effect)
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = UIColor.white
//        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        stackView.insertSubview(backgroundView, at: 0)
//
//        return stackView
//    }
//}
