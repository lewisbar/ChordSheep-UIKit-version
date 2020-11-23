//
//  DBManager.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 18.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

typealias BandID = String
typealias SongID = String
typealias ListID = String

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
    static let text = "text"
    static let timestamp = "timestamp"
    static let artist = "artist"
    static let key = "key"
    static let tempo = "tempo"
    static let signature = "signature"
    static let body = "body"
    static let index = "index"
}


struct DBManager {
    static let db = Firestore.firestore()
    static let bands = db.collection(Collections.bands)
    static let users = db.collection(Collections.users)
    
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
    
    static func create(song: Song) {
        bands.document(song.bandID).collection(Collections.songs).document(song.id).setData([Fields.text: song.text]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    static func create(list: Songlist) {
        var dict = [String: Any]()
        dict["title"] = list.title
        dict["timestamp"] = list.timestamp
        dict["index"] = list.index
        
        bands.document(list.bandID).collection(Collections.lists).document(list.id).setData(dict) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    // MARK: - Deleting
    static func delete(band: Band) {
        bands.document(band.id).delete()
        // TODO: Subcollections should be deleted, too, but this is only possible via a cloud function (if at all). Maybe I can just leave the stuff there?
    }
    
    static func delete(song: Song) {
        bands.document(song.bandID).collection(Collections.songs).document(song.id).delete()
        // TODO: Handle playlists that use that song
    }
    
    static func delete(list: Songlist) {
        bands.document(list.bandID).collection(Collections.lists).document(list.id).delete()
    }
    
    
    // MARK: - Renaming
    static func rename(band: Band, to name: String) {
        bands.document(band.id).setData(["name": name], merge: true)
    }
    
    static func update(song: Song) {
        create(song: song)
    }
    
    static func rename(list: Songlist, to title: String) {
        bands.document(list.bandID).collection(Collections.lists).document(list.id).setData([Fields.title: title], merge: true)
    }
        
    
    // MARK: - Reordering
    static func move(band: Band, fromIndex: Int, toIndex: Int) {
        // TODO. But drag and drop reordering of bands has not been implemented anyway as of now.
    }
    
    static func set(index: Int, for list: Songlist) {
        bands.document(list.bandID).collection(Collections.lists).document(list.id).setData([Fields.index: index], merge: true)
    }
    
    static func updateSongRefs(for list: Songlist) {
        var dict = [Int: DocumentReference]()
        
        // Use the songRefs array to create a dictionary
        for (index, songRef) in list.songRefs.enumerated() {
            dict[index] = songRef
        }
        bands.document(list.bandID).collection(Collections.lists).document(list.id).setData([Fields.songs: dict], merge: true)
    }
    
    
    // MARK: - Loading Data from Database
    static func listenForAllSongs(in bandID: BandID, onChange: (_ songs: [Song]) -> ()) -> ListenerRegistration? {
        return bands.document(bandID).collection(Collections.songs).order(by: "title").addSnapshotListener() { snapshot, error in
            guard let documents = snapshot?.documents else {
                print(error!.localizedDescription)
                return
            }
            onChange(documents.map { Song(with: $0.data()[Fields.text] as? String ?? "Song has no text") })
        }
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


// MARK: - Helper Functions
extension DBManager {
    
    static func generateDocumentID(type: DocumentType, name: String) -> String {
        // Create date stamp
        let formatter = DateFormatter()
        formatter.dateFormat = "y-M-d H:m:s-SSSS"
        let stamp = formatter.string(from: Date())
        
        // Remove unallowed characters
        let characterSet = CharacterSet(charactersIn: "./")
        let components = name.components(separatedBy: characterSet)
        let filteredName = components.joined(separator: "")
        
        return type.rawValue + filteredName + stamp
    }
//
//    static func dict(for song: Song) -> [String: Any] {
//        var dict = [String: Any]()
//        dict[Fields.text] = song.text
//        dict[Fields.title] = song.title
//        dict[Fields.timestamp] = song.timestamp
//        if let artist = song.artist { dict[Fields.artist] = artist }
//        if let key = song.key { dict[Fields.key] = key }
//        if let tempo = song.tempo { dict[Fields.tempo] = tempo }
//        if let signature = song.signature { dict[Fields.signature] = signature }
//        if let body = song.body { dict[Fields.body] = body }
//        return dict
//    }
}
