//
//  DBManager.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 18.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

struct Collections {
    static let users = "users"
    static let bands = "bands"
    static let songs = "songs"
    static let lists = "lists"
}

struct Fields {
    static let name = "name"
    static let title = "title"
    static let songs = "songs"
}

struct DBManager {
    // MARK: - Top Level: Contains Users and Bands
    static func createUser(name: String, in database: Firestore, completion: @escaping (_ user: User) -> ()) {
        var ref: DocumentReference? = nil
        ref = database.collection(Collections.users).addDocument(data: [Fields.name: name]) { error in
            if let error = error {
                print("User could not be added to database. -", error.localizedDescription)
            } else if let ref = ref {
                completion(User(name: name, ref: ref))
            }
        }
    }
    static func deleteUser(ref: DocumentReference) {
        ref.delete()
    }
    
    static func createBand(name: String, in database: Firestore, completion: @escaping (_ band: Band) -> ()) {
        var ref: DocumentReference? = nil
        ref = database.collection(Collections.bands).addDocument(data: [Fields.name: name]) { error in
            if let error = error {
                print("Band could not be added to database. -", error.localizedDescription)
            } else if let ref = ref {
                completion(Band(name: name, ref: ref))
            }
        }
    }
    static func deleteBand(ref: DocumentReference) {
        ref.delete()
        // TODO: Subcollections should be deleted, too, but this is only possible via a cloud function (if at all). Maybe I can just leave the stuff there?
    }
    
    
    // MARK: - Band Level: Contains Songs and Lists
    static func createSong(text: String, in bandRef: DocumentReference, completion: @escaping (_ song: Song) -> ()) {
        var song = Song(with: text)
        var ref: DocumentReference? = nil
        ref = bandRef.collection(Collections.songs).addDocument(data: song.dict) { error in
            if let error = error {
                print("Song could not be added to database. -", error.localizedDescription)
            } else if let ref = ref {
                song.ref = ref
                completion(song)
            }
        }
    }
    static func deleteSong(ref: DocumentReference) {
        ref.delete()
    }
    
    static func createList(in bandRef: DocumentReference, completion: @escaping (_ list: Songlist) -> ()) {
        // Create timestamp and date-based default title
        let timestamp = Timestamp(date: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = formatter.string(from: timestamp.dateValue())
        
        var list = Songlist(title: formattedDate, timestamp: timestamp)
        var ref: DocumentReference? = nil
        ref = bandRef.collection(Collections.lists).addDocument(data: list.dataDict) { error in
            if let error = error {
                print("Songlist could not be added to database. -", error.localizedDescription)
            } else if let ref = ref {
                list.ref = ref
                completion(list)
            }
        }
    }
    static func deleteList(ref: DocumentReference) {
        ref.delete()
    }
    
    
    // MARK: - List Level: Contains Song References
    static func addSong(ref: DocumentReference, to list: inout Songlist, at index: Int) {
        if index < list.songRefs.count {
            list.songRefs.insert(ref, at: index)
        } else {
            list.songRefs.append(ref)
        }
        list.ref?.setData([Fields.songs: list.songRefDict], merge: true)
    }
    static func removeSong(at index: Int, from list: inout Songlist) {
        list.songRefs.remove(at: index)
        list.ref?.setData([Fields.songs: list.songRefDict], merge: true)
    }
}
