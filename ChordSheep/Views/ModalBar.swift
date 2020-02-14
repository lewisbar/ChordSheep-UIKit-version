//
//  ModalBar.swift
//  Choly
//
//  Created by Lennart Wisbar on 12.09.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

protocol ModalBarDelegate: AnyObject {
    func cancelButtonPressed()
    func doneButtonPressed()
}

class ModalBar: UIView {

    weak var delegate: ModalBarDelegate?
    
    convenience init(delegate: ModalBarDelegate, backgroundColor: UIColor = PaintCode.dark, tintColor: UIColor = .white) {
        self.init()
        self.delegate = delegate
        
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        
        let cancelButton = UIButton.discreteButton(backgroundImage: PaintCode.imageOfCancelButton, target: self, action: #selector(cancelButtonPressed))
        // cancelButton.setTitle("X", for: .normal)
        // cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        
        let doneButton = UIButton.discreteButton(backgroundImage: PaintCode.imageOfSaveButton, target: self, action: #selector(doneButtonPressed))
//        let doneButton = UIButton(type: .system)
//        doneButton.setTitle("√", for: .normal)
//        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        self.addSubview(cancelButton)
        self.addSubview(doneButton)
        
        // AutoLayout
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            cancelButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            doneButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.heightAnchor.constraint(equalToConstant: 44)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    @objc func cancelButtonPressed() {
        self.delegate?.cancelButtonPressed()
    }
    @objc func doneButtonPressed() {
        self.delegate?.doneButtonPressed()
    }
}
