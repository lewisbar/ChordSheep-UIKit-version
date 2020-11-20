//
//  DBManager.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 18.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

enum DocumentType: String {
    case user, band, song, list
}

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
    static let db = Firestore.firestore()
    static let bands = db.collection(Collections.bands)
    static let users = db.collection(Collections.users)

    static func generateDocumentID(type: DocumentType, name: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-M-d H:m:s.SSSS"
        let stamp = formatter.string(from: Date())
        return type.rawValue + name + stamp
    }
    
//    // Top Level: Contains Users and Bands
//    static func create(user: inout User) {
//        let db = Firestore.firestore()
//        let dict = [Fields.name: user.name]
//        var ref: DocumentReference? = nil
//
//        ref = db.collection(Collections.users).addDocument(data: dict) { error in
//            if let error = error {
//                print("User could not be added to database. -", error.localizedDescription)
//            } else if let ref = ref {
//                user.ref = ref
//            }
//        }
//    }
//    static func deleteUser(ref: DocumentReference) {
//        ref.delete()
//    }
    
    // MARK: - Creating
    static func create(band: Band, id: String) {
        let dict = [Fields.name: band.name]
        
        bands.document(id).setData(dict) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    static func create(list: Songlist, in bandID: String, id: String) {
        var dict = [String: Any]()
        dict["title"] = list.title
        dict["timestamp"] = list.timestamp
        dict["index"] = list.index
        
        bands.document(bandID).collection(Collections.lists).document(list.id).setData(dict) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    static func create(song: Song, in bandID: String, id: String) {
        // TODO
    }
    
    
    // MARK: - Deleting
    static func delete(band: Band) {
        bands.document(band.id).delete()
        // TODO: Subcollections should be deleted, too, but this is only possible via a cloud function (if at all). Maybe I can just leave the stuff there?
    }
    
    static func delete(list: Songlist, from bandID: String) {
        bands.document(bandID).collection(Collections.lists).document(list.id).delete()
    }
    
    
    // MARK: - Renaming
    static func rename(band: Band, to name: String) {
        bands.document(band.id).setData(["name": name], merge: true)
    }
    
    static func rename(list: Songlist, in bandID: String, to name: String) {
        bands.document(bandID).collection(Collections.lists).document(list.id).setData([Fields.title: name], merge: true)
    }
    
    
    // MARK: - Reordering
    static func move(band: Band, fromIndex: Int, toIndex: Int) {
        // TODO
    }
    
    static func move(list: Songlist, in bandID: String, fromIndex: Int, toIndex: Int) {
        // TODO
    }
    
    static func move(songRef: DocumentReference, in list: Songlist) {
        // TODO
    }
    
    
    // MARK: - Adding to and removing from lists
    static func add(songRef: DocumentReference, to list: Songlist, in bandID: String) {
        // TODO
    }
    
    static func remove(songRef: DocumentReference, from list: Songlist, in bandID: String) {
        // TODO
    }
    
    
    // Band Level: Contains Songs and Lists
//    static func createSong(text: String, in bandRef: DocumentReference, completion: @escaping (_ song: Song) -> ()) {
//        var song = Song(with: text)
//        var ref: DocumentReference? = nil
//        ref = bandRef.collection(Collections.songs).addDocument(data: song.dict) { error in
//            if let error = error {
//                print("Song could not be added to database. -", error.localizedDescription)
//            } else if let ref = ref {
//                song.ref = ref
//                completion(song)
//            }
//        }
//    }
//    static func deleteSong(ref: DocumentReference) {
//        ref.delete()
//    }
//
//    static func createList(in bandRef: DocumentReference, completion: @escaping (_ list: Songlist) -> ()) {
//        // Create timestamp and date-based default title
//        let timestamp = Timestamp(date: Date())
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let formattedDate = formatter.string(from: timestamp.dateValue())
//
//        var list = Songlist(title: formattedDate, timestamp: timestamp)
//        var ref: DocumentReference? = nil
//        ref = bandRef.collection(Collections.lists).addDocument(data: list.dataDict) { error in
//            if let error = error {
//                print("Songlist could not be added to database. -", error.localizedDescription)
//            } else if let ref = ref {
//                list.ref = ref
//                completion(list)
//            }
//        }
//    }
//    static func deleteList(ref: DocumentReference) {
//        ref.delete()
//    }
//
//
//    // List Level: Contains Song References
//    static func addSong(ref: DocumentReference, to list: inout Songlist, at index: Int) {
//        if index < list.songRefs.count {
//            list.songRefs.insert(ref, at: index)
//        } else {
//            list.songRefs.append(ref)
//        }
//        list.ref?.setData([Fields.songs: list.songRefDict], merge: true)
//    }
//    static func removeSong(at index: Int, from list: inout Songlist) {
//        list.songRefs.remove(at: index)
//        list.ref?.setData([Fields.songs: list.songRefDict], merge: true)
//    }
}
