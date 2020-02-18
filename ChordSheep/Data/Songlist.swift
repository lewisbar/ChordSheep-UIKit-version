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
    var date: Date?
    var ref: DocumentReference
    
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
    
    init(from dict: [String : Any], reference: DocumentReference) {
        self.title = dict["title"] as? String ?? ""
        self.date = dict["date"] as? Date
        if let songDict = dict["songs"] as? [String:DocumentReference] {
            self.songRefs = Songlist.refArray(from: songDict)
        }
        self.ref = reference
    }
    
    static func refArray(from dict: [String: DocumentReference]) -> [DocumentReference] {
        var refs = [DocumentReference]()
        for i in 0...dict.count-1 {
            refs.append(dict[String(i)]!)
        }
        return refs
    }
    
    var songRefDict: [String: DocumentReference] {
        var dict = [String: DocumentReference]()
        for i in 0...self.songRefs.count-1 {
            dict[String(i)] = self.songRefs[i]
        }
        return dict
    }
}


//extension Songlist: Equatable, Comparable {
//    
//    static func == (lhs: Songlist, rhs: Songlist) -> Bool {
//        return (lhs.title == rhs.title) &&
//            (lhs.songRefs == rhs.songRefs) &&
//            (lhs.date == rhs.date)
//    }
//    
//    static func < (lhs: Songlist, rhs: Songlist) -> Bool {
//        return lhs.title < rhs.title
//    }
//}
