//
//  DBManager.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 18.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

class DBManager {
    static func generateID(for doc: DatabaseStorable) -> DocID {
        // Create date stamp
        let formatter = DateFormatter()
        formatter.dateFormat = "y-M-d H:m:s-SSSS"
        let stamp = formatter.string(from: Date())
        
        // Remove unallowed characters
        let characterSet = CharacterSet(charactersIn: "./")
        let components = doc.name.components(separatedBy: characterSet)
        let filteredName = components.joined(separator: "")
        
        return filteredName + stamp
    }
    
    static func create(band: Band) {
        band.id = generateID(for: band)
        print("bands.document(band.id).setData(dict(for: band))")
    }
    
    static func create(song: Song, in band: Band) {
        song.id = generateID(for: song)
        print("bands.document(band.id).collection('songs').document(song.id).setData(dict(for: song))")
    }
    
    static func create(list: List, in band: Band) {
        list.id = generateID(for: list)
        print("bands.document(band.id).collection('lists').document(list.id).setData(dict(for: list))")
    }
}







typealias UserID = String
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


struct DBManagerOld {
    static var db: Firestore { Firestore.firestore() }
    static var bands: CollectionReference { db.collection(Collections.bands) }
    static var users: CollectionReference { db.collection(Collections.users) }
    
    // MARK: - Creating
    static func create(user: User) {
        let dict = [Fields.name: user.name]

        users.document(user.uid).setData(dict) { error in
            if let error = error {
                print("User could not be added to database. -", error.localizedDescription)
            } else {
                print("User successfully added.")
            }
        }
    }
    
    static func create(band: Band) {
        let dict = [Fields.name: band.name]
        
        bands.document(band.id).setData(dict) { error in
            if let error = error {
                print("Band could not be added to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func create(song: Song) {
        let dict = [Fields.text: song.text]
        
        bands.document(song.band.id).collection(Collections.songs).document(song.id).setData(dict) { error in
            if let error = error {
                print("Song could not be added to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func create(list: Songlist) {
        var dict = [String: Any]()
        dict["title"] = list.title
        dict["timestamp"] = list.timestamp
        dict["index"] = list.index
        
        bands.document(list.band.id).collection(Collections.lists).document(list.id).setData(dict) { error in
            if let error = error {
                print("Songlist could not be added to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    
    // MARK: - Deleting
    static func deleteUser(uid: UserID) {
        users.document(uid).delete()
    }
    
    static func delete(band: Band) {
        bands.document(band.id).delete()
        // TODO: Subcollections should be deleted, too, but this is only possible via a cloud function (if at all). Maybe I can just leave the stuff there?
    }
    
    static func delete(song: Song) {
        bands.document(song.band.id).collection(Collections.songs).document(song.id).delete()
        // TODO: Handle playlists that use that song
    }
    
    static func delete(list: Songlist) {
        bands.document(list.band.id).collection(Collections.lists).document(list.id).delete()
    }
    
    
    // MARK: - Renaming
    static func rename(user: User, to name: String) {
        users.document(user.uid).setData([Fields.name: name], merge: true)
    }
    
    static func rename(band: Band, to name: String) {
        bands.document(band.id).setData([Fields.name: name], merge: true)
    }
    
    static func update(song: Song) {
        create(song: song)
    }
    
    static func rename(list: Songlist, to title: String) {
        bands.document(list.band.id).collection(Collections.lists).document(list.id).setData([Fields.title: title], merge: true)
    }
        
    
    // MARK: - Reordering
    static func move(band: Band, fromIndex: Int, toIndex: Int) {
        // TODO. But drag and drop reordering of bands has not been implemented anyway as of now.
    }
    
    static func set(index: Int, for list: Songlist) {
        bands.document(list.band.id).collection(Collections.lists).document(list.id).setData([Fields.index: index], merge: true)
    }
    
    static func updateSongRefs(for list: Songlist) {
        var dict = [String: SongID]()
        
        // Use the songID array to create a dictionary
        for (index, songID) in list.songIDs.enumerated() {
            dict[String(index)] = songID
        }
        bands.document(list.band.id).collection(Collections.lists).document(list.id).setData([Fields.songs: dict], merge: true)
    }
    
    
    // MARK: - Listeners
    static func listenForAuthState(onChange: @escaping (_ user: User) -> ()) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let userAuth = user else { print("No user logged in"); return }
            let name = userAuth.displayName ?? userAuth.email ?? userAuth.phoneNumber ?? "Unknown User"
            let uid = userAuth.uid
            let user = User(name: name, uid: uid, isNew: false)
            onChange(user)
        }
    }
    
    static func listenForBands(with userID: UserID, onChange: @escaping (_ bands: [Band]) -> ()) -> ListenerRegistration {
        // Listen for bands the user is in
        return bands.whereField("members.\(userID)", isGreaterThan: -1).addSnapshotListener() { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("The user's bands could not be fetched. -", error!.localizedDescription)
                return
            }
            let bands = documents.map { makeBand(dict: $0.data(), id: $0.documentID) }
            onChange(bands)
        }
    }
    
    static func listenForLists(in band: Band, onChange: @escaping (_ lists: [Songlist]) -> ()) -> ListenerRegistration {
        return bands.document(band.id).collection(Collections.lists).order(by: Fields.index).addSnapshotListener() { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("The band's lists could not be fetched. -", error!.localizedDescription)
                return
            }
            let lists = documents.map { makeList(dict: $0.data(), id: $0.documentID, band: band) }
            onChange(lists)
        }
    }
    
    static func listenForAllSongs(in band: Band, onChange: @escaping (_ songs: [Song]) -> ()) -> ListenerRegistration {
        return bands.document(band.id).collection(Collections.songs).order(by: Fields.title).addSnapshotListener() { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("The band's songs could not be fetched. -", error!.localizedDescription)
                return
            }
            let songs = documents.map { makeSong(dict: $0.data(), id: $0.documentID, band: band) }
            onChange(songs)
        }
    }
    
    static func listenForList(_ list: Songlist, onChange: @escaping (_ list: Songlist) -> ()) -> ListenerRegistration {
        bands.document(list.band.id).collection(Collections.lists).document(list.id).addSnapshotListener() { snapshot, error in
            guard let songlistDict = snapshot?.data() else {
                print("Songlist could not be fetched. -", error!.localizedDescription)
                return
            }
            
            // Create a new list with the same IDs, but updated data
            let songlist = makeList(dict: songlistDict, id: list.id, band: list.band)
            onChange(songlist)
        }
    }
    
    static func getSongsFromList(_ list: Songlist, completion: @escaping (_ songs: [Song]) -> ()) {
        // Make sure the songs are put in the right order. Async fetching tends to mix them up.
        var songs = [Song](repeating: Song(), count: list.songIDs.count)
        
        for (i, songID) in list.songIDs.enumerated() {
            bands.document(list.band.id).collection(Collections.songs).document(songID).getDocument { document, error in
                guard let document = document else {
                    print("Song could not be fetched. -", error!.localizedDescription)
                    return
                }
                guard let data = document.data() else {
                    print("Song has no data.")
                    return
                }
                songs[i] = makeSong(dict: data, id: document.documentID, band: list.band)
            }
        }
        completion(songs)
    }
}


// MARK: - Helper Functions
extension DBManagerOld {
    
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

    
    // Creating Band, Song and List instances from existing database entries
    static func makeBand(dict: [String: Any], id: BandID) -> Band {
        let name = dict[Fields.name] as? String ?? ""
        let songs = dict[Collections.songs] as? [Song] ?? [Song]()
        let lists = dict[Collections.lists] as? [Songlist] ?? [Songlist]()
        return Band(name: name, songs: songs, lists: lists, isNew: false)
    }
    
    static func makeSong(dict: [String: Any], id: SongID, band: Band) -> Song {
        let text = dict[Fields.text] as? String ?? ""
        let timestamp = dict[Fields.timestamp] as? Timestamp ?? Timestamp(date: Date())
        return Song(text: text, id: id, band: band, timestamp: timestamp)
    }
    
    static func makeList(dict: [String: Any], id: SongID, band: Band) -> Songlist {
        let title = dict[Fields.title] as! String // ?? ""
        let timestamp = dict[Fields.timestamp] as! Timestamp // ?? Timestamp(date: Date())
        let index = dict[Fields.index] as! Int
        let songIDDict = dict[Fields.songs] as? [String: SongID] ?? [String: SongID]()
        
        var songIDs = [SongID]()
        for (i, _) in songIDDict.enumerated() {
            if let songID = songIDDict[String(i)] {
                songIDs.append(songID)
            }
        }
        
        return Songlist(title: title, id: id, band: band, timestamp: timestamp, index: index, songIDs: songIDs)
    }
}
