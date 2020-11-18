//
//  Band.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//


import Foundation
import Firebase

class Band {
    var name: String {
        didSet { ref.setData(["name": name], merge: true) }
    }
    var ref: DocumentReference
    var songlists: [Songlist] {
        didSet {
            for list in songlists {
                print(list.title, list.index)
            }
            // Update all indices to match the new situation
            for (index, _) in songlists.enumerated() {
                songlists[index].index = index
            }
        }
    }
    // var id: String!
    // var members = [String: Int]()
    
    init(name: String, ref: DocumentReference, songlists: [Songlist] = [Songlist]()) {
        self.name = name
        self.songlists = songlists
        self.ref = ref
    }
    
    func createSonglist(title: String, timestamp: Timestamp) -> Songlist {
        var songlist = Songlist(title: title, timestamp: timestamp, index: 0)
        songlists.insert(songlist, at: 0)
        songlist.ref = ref.collection("lists").addDocument(data: songlist.dataDict)
        return songlist
    }
    
    func deleteSonglist(ref: DocumentReference) {
        ref.delete()
    }
    
    func createSong(with text: String) -> DocumentReference {
        let song = Song(with: text)
        return ref.collection("songs").addDocument(data: song.dict)
    }
}


//extension Band: Equatable, Comparable {
//    static func == (lhs: Band, rhs: Band) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    static func < (lhs: Band, rhs: Band) -> Bool {
//        return lhs.name < rhs.name
//    }
//}
