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
        self.songRefs = Songlist.refArray(from: (dict["songs"] as! [String: DocumentReference]))
        self.ref = reference
    }
    
    static func refArray(from dict: [String: DocumentReference]) -> [DocumentReference] {
        var refs = [DocumentReference]()
        for i in 0...dict.count-1 {
            refs.append(dict[String(i)]!)
        }
        return refs
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
