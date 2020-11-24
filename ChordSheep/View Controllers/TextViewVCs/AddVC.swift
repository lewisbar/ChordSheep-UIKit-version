//
//  AddVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 03.03.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

protocol AddVCDelegate: AnyObject {
    func receive(newText: String)
}

// TODO: Add a title label in the ModalBar that gets filled automatically. Maybe even more meta data that just the title, preferably all of it, so you get immediate feedback what your input will produce.
class AddVC: TextViewVC {

    weak var delegate: AddVCDelegate?
    
    override func doneButtonPressed() {
        songTextView.resignFirstResponder()  // Otherwise the keyboard disappears a bit after the AddVC
        
        self.delegate?.receive(newText: self.songTextView.text)
        dismiss(animated: true)
    }
}
