//
//  EditVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 15.02.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

protocol EditVCDelegate: AnyObject {
    func update(song: Song, with text: String)
}

class EditVC: TextViewVC {
    
    weak var delegate: EditVCDelegate?
    var song: Song
    
    init(song: Song, delegate: EditVCDelegate) {
        self.song = song
        self.delegate = delegate
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
        self.delegate?.update(song: song, with: songTextView.text)
        dismiss(animated: true)
    }
}
