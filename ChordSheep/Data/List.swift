//
//  List.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation

class List: DatabaseStorable {
    var id: DocID?  // If nil, list has not been saved to db yet.
    var name: String
    private(set) var songs: [Song]
    private(set) var index: Int
    
    init(id: DocID? = nil, index: Int = 0, name: String = "", songs: [Song] = [Song]()) {
        self.id = id
        self.index = index
        self.name = name
        self.songs = songs
    }
    
    // Songs and other private(set) vars should only be changed via DBStore, so the changes get saved to the database. While it's still possible for any class to change the songs, because the songs array is private(set), you have to use the methods below to modify it, so you'll hopefully won't do it by accident. These methods should generally only be called by the DBStore class (unless you know what you're doing, meaning: Your changes won't be saved to the database).
    func set(songs: [Song]) {
        self.songs = songs
    }
    func moveSong(fromIndex: Int, toIndex: Int) {
        songs.moveElement(fromIndex: fromIndex, toIndex: toIndex)
    }
    func insert(song: Song, at index: Int) {
        songs.insert(song, at: index)
    }
    func append(song: Song) {
        songs.append(song)
    }
    func removeSong(at index: Int) {
        songs.remove(at: index)
    }
    
    func set(index: Int) {
        self.index = index
    }
}




//struct ListOld {
//    
//    let id: String
//    let band: Band
//    let timestamp: Timestamp
//    
//    var title: String { didSet { DBManager.rename(list: self, to: title) } }
//    var index: Int
//    var songIDs: [SongID]
//    
//    
//    init(title: String, id: ListID, band: Band, timestamp: Timestamp, index: Int = 0, songIDs: [SongID] = [SongID]()) {
//        /* This is the initializer for creating a new songlist (as opposed to initializing an existing one from the database). To be called via band.create(songlist:title)*/
//        self.band = band
//        self.title = title
//        self.timestamp = timestamp
//        self.id = id
//        self.index = index
//        self.songIDs = songIDs
//    }
//    
//    mutating func moveSong(fromIndex: Int, toIndex: Int) {
//        songIDs.moveElement(fromIndex: fromIndex, toIndex: toIndex)
//        DBManager.updateSongRefs(for: self)
//    }
//    
//    mutating func add(songID: SongID, at index: Int) {
//        songIDs.insert(songID, at: index)
//        DBManager.updateSongRefs(for: self)
//    }
//    
//    mutating func removeSong(at index: Int) {
//        songIDs.remove(at: index)
//        DBManager.updateSongRefs(for: self)
//    }
//}
    
//    init(from dict: [String : Any], ref: DocumentReference) {
//        /* This is the initializer for existing songs in the database (as opposed to creating a new song). */
//        self.ref = ref
//        self.title = dict["title"] as? String ?? ""
//        if let timestamp = dict["timestamp"] as? Timestamp {
//            self.timestamp = timestamp
//        } else {
//            // If the list, for some reason, has no timestamp, create one and add it to the document
//            self.timestamp = Timestamp(date: Date())
//            self.ref?.setData(["timestamp": timestamp], merge: true)
//            print("Songlist \(self.title) has no timestamp. Using new timestamp.")
//        }
//        // self.timestamp = dict["timestamp"] as! Timestamp  // ?? Timestamp(date: Date())
//        if let songDict = dict["songs"] as? [String:DocumentReference] {
//            self.songRefs = Songlist.refArray(from: songDict)
//        }
//        if let i = dict["index"] as? Int {
//            self.index = i  // dict["index"] as! Int
//        } else {
//            self.index = 99  // TODO: No good solution. This should never happen, but you never know.
//            print(self.title, "has no index.")
//        }
//    }
    
    
//    var dataDict: [String: Any] {
//        var dict = [String: Any]()
//        dict["title"] = self.title
//        dict["timestamp"] = self.timestamp
//        dict["songs"] = self.songRefDict
//        dict["index"] = self.index
//        return dict
//    }
//
//    static func refArray(from dict: [String: DocumentReference]) -> [DocumentReference] {
//        var refs = [DocumentReference]()
//        guard dict.count > 0 else { return refs }
//        for i in 0...dict.count-1 {
//            if let songRef = dict[String(i)] {
//                refs.append(songRef)
//            }
//        }
//        return refs
//    }
//
//    var songRefDict: [String: DocumentReference] {
//        var dict = [String: DocumentReference]()
//        guard self.songRefs.count > 0 else { return dict }
//        for i in 0...self.songRefs.count-1 {
//            dict[String(i)] = self.songRefs[i]
//        }
//        return dict
//    }


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
