//
//  EditVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 15.02.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class EditVC: TextViewVC {
    let song: Song
    
    init(store: DBStore, song: Song, band: Band) {
        self.song = song
        super.init(store: store, band: band)
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
        store.retext(song: song, in: band, with: songTextView.text)
        dismiss(animated: true)
    }
    
    override func databaseDidChange(changedItems: [DatabaseStorable]) {
        // TODO: What to do if the song changes while the user is editing it? Notify the user?
    }
}
