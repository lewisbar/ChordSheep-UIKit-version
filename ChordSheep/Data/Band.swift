//
//  Band.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//


import Foundation

class Band: DatabaseStorable {
    var id: DocID?  // If nil, band has not been saved to db yet.
    var name: String
    private(set) var songs: [Song]
    private(set) var lists: [List]
    private(set) var index = 0
    
    init(id: DocID? = nil, name: String = "", songs: [Song] = [Song](), lists: [List] = [List]()) {
        self.id = id
        self.name = name
        self.songs = songs
        self.lists = lists
    }
    
    // Songs and lists and other private(set) vars should only be changed via DBStore, so the changes get saved to the database. While it's still possible for any class to change the songs or lists, because the songs and list arrays are private(set), you have to use the methods below to modify them, so you'll hopefully won't do it by accident. These methods should generally only be called by the DBStore class (unless you know what you're doing, meaning: Your changes won't be saved to the database).
    func set(songs: [Song]) {
        self.songs = songs
    }
    func moveSong(fromIndex: Int, toIndex: Int) {
        songs.moveElement(fromIndex: fromIndex, toIndex: toIndex)
    }
    func insert(song: Song, at index: Int) {
        songs.insert(song, at: index)
    }
    func removeSong(at index: Int) {
        songs.remove(at: index)
    }
    
    func set(lists: [List]) {
        self.lists = lists
    }
    // The following methods should only be called from DBStore. They don't update the indices themselves.
    func moveList(fromIndex: Int, toIndex: Int) {
        lists.moveElement(fromIndex: fromIndex, toIndex: toIndex)
    }
    func insert(list: List, at index: Int) {
        lists.insert(list, at: index)
    }
    func removeList(at index: Int) {
        lists.remove(at: index)
    }
    
    func set(index: Int) {
        self.index = index
    }
}


//struct BandOld {
//    let id: String
//
//    var name: String { didSet { DBManager.rename(band: self, to: name) } }
//    var songs: [Song]
//    var lists: [Songlist]
//    
//    init(name: String, songs: [Song] = [Song](), lists: [Songlist] = [Songlist](), isNew: Bool) {
//        self.name = name
//        self.id = DBManager.generateDocumentID(type: .band, name: self.name)
//        self.songs = songs
//        self.lists = lists
//        if isNew {
//            DBManager.create(band: self)
//        }
//    }
//    
//    func delete() {
//        DBManager.delete(band: self)
//    }
//    
//    func createSong(text: String, timestamp: Timestamp) -> Song {
//        let songID = DBManager.generateDocumentID(type: .song, name: String(text.prefix(20)))
//        let song = Song(text: text, id: songID, band: self, timestamp: timestamp)
//        DBManager.create(song: song)
//        return song
//    }
//    
//    mutating func createList(title: String, timestamp: Timestamp) -> Songlist {
//        // Prepare the other lists' indices to make room at position 0
//        for (i, _) in lists.enumerated() {
//            let index = i + 1
//            lists[index].index = index
//            DBManager.set(index: index, for: lists[index])
//        }
//        
//        // Create the new list
//        let listID = DBManager.generateDocumentID(type: .list, name: title)
//        let newList = Songlist(title: title, id: listID, band: self, timestamp: timestamp)
//        lists.insert(newList, at: lists.startIndex)
//        DBManager.create(list: newList)
//        
//        return newList
//    }
//    
//    func delete(song: Song) {
//        DBManager.delete(song: song)
//    }
//    
//    func delete(list: Songlist) {
//        DBManager.delete(list: list)
//    }
//
//    mutating func moveList(fromIndex: Int, toIndex: Int) {
//        lists.moveElement(fromIndex: fromIndex, toIndex: toIndex)
//        
//        // Update indices
//        for index in min(fromIndex, toIndex)...max(fromIndex, toIndex) {
//            lists[index].index = index
//            DBManager.set(index: index, for: lists[index])
//        }
//    }
//}


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
