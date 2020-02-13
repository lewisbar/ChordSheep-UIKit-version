//
//  AddVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 03.03.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

protocol AddVCDelegate: AnyObject {
    func receive(newSong: Song)
}

class AddVC: TextViewVC {

    weak var delegate: AddVCDelegate?
    
    override func doneButtonPressed() {
        songTextView.resignFirstResponder()  // Otherwise the keyboard disappears a bit after the AddVC
        
        self.delegate?.receive(newSong: Song(with: self.songTextView.text))
        dismiss(animated: true)
    }
}
