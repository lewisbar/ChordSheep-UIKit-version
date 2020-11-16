//
//  EditVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 15.02.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class EditVC: TextViewVC {
    
    var song: Song
    
    init(song: Song) {
        self.song = song
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songTextView.text = song.text
    }
    
    override func doneButtonPressed() {
        songTextView.resignFirstResponder()  // Otherwise the keyboard disappears a bit after the AddVC
        song.text = songTextView.text
        dismiss(animated: true)
    }
}
