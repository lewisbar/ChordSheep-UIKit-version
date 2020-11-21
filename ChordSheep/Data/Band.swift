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
    let id: String

    var name: String { didSet { DBManager.rename(band: self, to: name) } }
    var lists = [Songlist]()
    
    init(name: String) {
        self.name = name
        self.id = DBManager.generateDocumentID(type: .band, name: self.name)
        DBManager.create(band: self, id: self.id)
    }
    
    func delete() {
        DBManager.delete(band: self)
    }
    
    mutating func moveList(fromIndex: Int, toIndex: Int) {
        let list = lists.remove(at: fromIndex)
        lists.insert(list, at: toIndex)
        
        // Update indices
        for index in min(fromIndex, toIndex)...max(fromIndex, toIndex) {
            lists[index].index = index
            DBManager.set(index: index, for: lists[index])
        }
    }
}


    // var songs: [Song]  // TODO: Is it necessary to initialize all bands' songs everytime I open the app? I think not, so I commented this line.

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
