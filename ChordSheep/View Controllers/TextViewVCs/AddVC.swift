//
//  AddVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 03.03.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

// TODO: Add a title label in the ModalBar that gets filled automatically. Maybe even more meta data that just the title, preferably all of it, so you get immediate feedback what your input will produce.
class AddVC: TextViewVC {
    
    override func databaseDidChange(changedItems: [DatabaseStorable]) {
        // TODO: React to weird events like when the current band has just been deleted?
    }
    
    override func doneButtonPressed() {
        songTextView.resignFirstResponder()  // Otherwise the keyboard disappears a bit after the AddVC
        let song = Song(text: songTextView.text)
        store.store(song: song, in: band)
        dismiss(animated: true)
    }
}
