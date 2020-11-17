//
//  Band.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

// TODO: It could be that I don't need this class.

import Foundation
import Firebase

class Band {
    var name: String {
        didSet { ref.setData(["name": name], merge: true) }
    }
    var ref: DocumentReference
    var songlists: [Songlist] {
        didSet {
            for (index, _) in songlists.enumerated() {
                songlists[index].index = index
            }
        }
    }
    // var id: String!
    // var members = [String: Int]()
    
    init(name: String, ref: DocumentReference, songlists: [Songlist] = [Songlist]()) {
        self.name = name
        self.ref = ref
        self.songlists = songlists
    }
    
    func createSonglist(title: String, timestamp: Timestamp) -> Songlist {
        let songlist = Songlist(title: title, timestamp: timestamp, index: 0)
        ref.collection("lists").addDocument(data: songlist.dataDict)
        
        // Update the other lists' indices so the new list can take its place at the top
        for list in songlists {
            let newIndex = list.index + 1
            list.ref?.setData(["index": newIndex], merge: true)
        }
        
        return songlist
    }
    
    func deleteSonglist(ref: DocumentReference) {
        ref.delete()
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
