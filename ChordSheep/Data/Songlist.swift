//
//  Songlist.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase


struct Songlist: DocumentSerializable {
    
    var title = "" {
        didSet {
            print("new title:", title)
            self.ref?.setData(["title": title], merge: true) }
    }
    var songRefs = [DocumentReference]() {
        didSet {
            print("songrefs updated")
            self.ref?.setData(["songs": songRefDict], merge: true) }
    }
    var timestamp: Timestamp {
        didSet {
            print("new timestamp:", timestamp)
            self.ref?.setData(["timestamp": timestamp], merge: true)
        }
    }
    var index: Int {
        didSet {
            print("index of \(title) set")
            self.ref?.setData(["index": index], merge: true)
        }
    }
    var ref: DocumentReference?
    
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
    
    init(from dict: [String : Any], reference: DocumentReference) {
        /* This is the initializer for existing songs in the database (as opposed to creating a new song). */
        self.ref = reference
        self.title = dict["title"] as? String ?? ""
        if let timestamp = dict["timestamp"] as? Timestamp {
            self.timestamp = timestamp
        } else {
            // If the list, for some reason, has no timestamp, create one and add it to the document
            self.timestamp = Timestamp(date: Date())
            self.ref?.setData(["timestamp": timestamp], merge: true)
            print("Songlist \(self.title) has no timestamp. Using new timestamp.")
        }
        // self.timestamp = dict["timestamp"] as! Timestamp  // ?? Timestamp(date: Date())
        if let songDict = dict["songs"] as? [String:DocumentReference] {
            self.songRefs = Songlist.refArray(from: songDict)
        }
        if let i = dict["index"] as? Int {
            self.index = i  // dict["index"] as! Int
        } else {
            self.index = 99  // TODO: No good solution. This should never happen, but you never know.
            print(self.title, "has no index.")
        }
    }
    
    init(title: String, timestamp: Timestamp, index: Int) {
        /* This is the initializer for creating a new songlist (as opposed to initializing an existing one from the database). To be called via band.create(songlist:title)*/
        self.title = title
        self.timestamp = timestamp
        self.index = index
    }
    
    var dataDict: [String: Any] {
        var dict = [String: Any]()
        dict["title"] = self.title
        dict["timestamp"] = self.timestamp
        dict["songs"] = self.songRefDict
        dict["index"] = self.index
        return dict
    }
    
    static func refArray(from dict: [String: DocumentReference]) -> [DocumentReference] {
        var refs = [DocumentReference]()
        guard dict.count > 0 else { return refs }
        for i in 0...dict.count-1 {
            if let songRef = dict[String(i)] {
                refs.append(songRef)
            }
        }
        return refs
    }
    
    var songRefDict: [String: DocumentReference] {
        var dict = [String: DocumentReference]()
        guard self.songRefs.count > 0 else { return dict }
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
