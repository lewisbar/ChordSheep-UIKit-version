//
//  TextViewVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 14.04.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class TextViewVC: UIViewController, ModalBarDelegate, DatabaseDependent {
    var store: DBStore
    let band: Band
    let songTextView = UITextView()
    
    init(store: DBStore, band: Band) {
        self.store = store
        self.band = band
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let topBar = UIView()
//        topBar.backgroundColor = .black
//
//        let cancelButton = UIButton(type: .system)
//        cancelButton.setTitle("X", for: .normal)
//        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
//
//        let saveButton = UIButton(type: .system)
//        saveButton.setTitle("√", for: .normal)
//        saveButton.addTarget(self, action: #selector(saveButtonPressed(_:)), for: .touchUpInside)
//
//        topBar.addSubview(cancelButton)
//        topBar.addSubview(saveButton)
        
        let topBar = ModalBar(delegate: self)
        
        songTextView.backgroundColor = PaintCode.dark
        songTextView.textColor = PaintCode.light
        
        let stackView = UIStackView(arrangedSubviews: [topBar, songTextView])
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        
//        cancelButton.translatesAutoresizingMaskIntoConstraints = false
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
        topBar.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [
//            cancelButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 8),
//            cancelButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
//            saveButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -8),
//            saveButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
//            topBar.heightAnchor.constraint(equalToConstant: 44),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        // Use Safe Area for top and bottom if available
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            constraints.append(stackView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0))
            constraints.append(guide.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1.0))
        } else {
            let standardSpacing: CGFloat = 8.0
            constraints.append(stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing))
            constraints.append(bottomLayoutGuide.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: standardSpacing))
        }
        
        NSLayoutConstraint.activate(constraints)
    }

    func databaseDidChange(changedItems: [DatabaseStorable]) {
        // Implement in subclasses
    }
    
    // ModalBarDelegate
    func cancelButtonPressed() {
        songTextView.resignFirstResponder()  // Otherwise the keyboard disappears a bit after the AddVC
        dismiss(animated: true)
    }
        
    func doneButtonPressed() {
        songTextView.resignFirstResponder()  // Otherwise the keyboard disappears a bit after the AddVC
        dismiss(animated: true)
    }
}
