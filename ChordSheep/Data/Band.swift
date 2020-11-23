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
        lists.moveElement(fromIndex: fromIndex, toIndex: toIndex)
        
        // Update indices
        for index in min(fromIndex, toIndex)...max(fromIndex, toIndex) {
            lists[index].index = index
            DBManager.set(index: index, for: lists[index])
        }
    }
    
    mutating func createList(title: String, timestamp: Timestamp) {
        // Prepare the other lists' indices to make room at position 0
        for (i, _) in lists.enumerated() {
            let index = i + 1
            lists[index].index = index
            DBManager.set(index: index, for: lists[index])
        }
        
        // Create the new list
        let listID = DBManager.generateDocumentID(type: .list, name: title)
        let newList = Songlist(title: title, id: listID, bandID: self.id, timestamp: timestamp)
        lists.insert(newList, at: lists.startIndex)
        DBManager.create(list: newList)
    }
    
    func delete(list: Songlist) {
        DBManager.delete(list: list, from: id)
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
