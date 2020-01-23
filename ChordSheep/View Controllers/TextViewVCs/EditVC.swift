//
//  EditVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 15.02.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

protocol EditVCDelegate: AnyObject {
    func updateSong(with text: String)
}

class EditVC: TextViewVC {
    
    weak var delegate: EditVCDelegate?
    
    override func doneButtonPressed() {
        songTextView.resignFirstResponder()  // Otherwise the keyboard disappears a bit after the AddVC
        self.delegate?.updateSong(with: songTextView.text)
        dismiss(animated: true)
    }
}
