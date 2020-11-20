//
//  Band.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//


import Foundation
import Firebase

struct Band {
    var name: String { didSet { DBManager.rename(band: self, to: name) } }
    let id: String
    
    init(name: String) {
        self.name = name
        self.id = DBManager.generateDocumentID(type: .band, name: self.name)
        DBManager.create(band: self, id: self.id)
    }
    
    func delete() {
        DBManager.delete(band: self)
    }
}


    // var songs: [Song]  // TODO: Is it necessary to initialize all bands' songs everytime I open the app? I think not, so I commented this line.
//    var songlists: [Songlist] {
//        didSet {
//            for list in songlists {
//                print(list.title, list.index)
//            }
//            // Update all indices to match the new situation
//            for (index, _) in songlists.enumerated() {
//                songlists[index].index = index
//            }
//        }
//    }
    // var members = [String: Int]()

    
    
    
//    init(from dict: [String: Any], ref: DocumentReference) {
//        self.ref = ref
//        self.name = dict["name"] as? String ?? ""
//
//        self.name = name
//        self.songlists = songlists
//        self.ref = ref
//    }
//
//    func createSonglist(title: String, timestamp: Timestamp) -> Songlist {
//        var songlist = Songlist(title: title, timestamp: timestamp, index: 0)
//        songlists.insert(songlist, at: 0)
//        songlist.ref = ref.collection("lists").addDocument(data: songlist.dataDict)
//        return songlist
//    }
//
//    func deleteSonglist(ref: DocumentReference) {
//        ref.delete()
//    }
//
//    func createSong(with text: String) -> DocumentReference {
//        let song = Song(with: text)
//        return ref.collection("songs").addDocument(data: song.dict)
//    }
//}
