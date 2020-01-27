//
//  Importer.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 27.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

struct Importer {
    static func text(_ text: String, bandID: String) {
        let db = Firestore.firestore()
        let song = Song(with: text)
        db.collection("bands").document(bandID).collection("songs").addDocument(data: song.dict)
    }
    
    // static func textFile(_ file: ...)
    // static func onsongFile(_ file: ...)
}
