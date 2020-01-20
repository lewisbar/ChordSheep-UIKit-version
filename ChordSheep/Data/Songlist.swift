//
//  Songlist.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase


struct Songlist {
    
    var title = ""
    var songRefs = [DocumentReference]()
    lazy var songs: [Song] = computeSongs()
    var date: Date?
    
    func computeSongs() -> [Song] {
        var songs = [Song]()
        for songRef in songRefs {
            songRef.getDocument() {
                songDoc, error in
                guard let songDoc = songDoc else {
                    print(error!.localizedDescription)
                    return
                }
                guard let songData = songDoc.data() else {
                    print("Song document is empty")
                    return
                }
                songs.append(Song(from: songData))
            }
        }
        return songs
    }
//    var dictionary: [String: Any] {
//        if let date = date {
//            return [
//                "title": title,
//                "songs": songs,
//                "date": date
//            ]
//        }
//        return [
//            "title": title,
//            "songs": songs
//        ]
//    }
}

extension Songlist: DocumentSerializable {
    
    init(from dict: [String : Any]) {
        self.title = dict["title"] as? String ?? ""
        self.date = dict["date"] as? Date
        self.songRefs = dict["songs"] as? [DocumentReference] ?? []
    }
}


extension Songlist: Equatable, Comparable {
    
    static func == (lhs: Songlist, rhs: Songlist) -> Bool {
        return (lhs.title == rhs.title) &&
            (lhs.songRefs == rhs.songRefs) &&
            (lhs.date == rhs.date)
    }
    
    static func < (lhs: Songlist, rhs: Songlist) -> Bool {
        return lhs.title < rhs.title
    }
}
