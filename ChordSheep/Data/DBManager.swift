//
//  DBManager.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 18.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

typealias UserID = String
typealias BandID = String
typealias SongID = String
typealias ListID = String


class DBManager {
//    enum DocumentType: String {
//        case user, band, song, list
//    }

    struct Collections {
        static let users = "users", bands = "bands", songs = "songs", lists = "lists"
    }

    struct Fields {
        static let name = "name", title = "title", songs = "songs", text = "text", created = "created", modified = "modified", artist = "artist", key = "key", tempo = "tempo", signature = "signature", body = "body", index = "index", bandAccess = "bandAccess"
    }
    
    static var db: Firestore { Firestore.firestore() }
    static var bands: CollectionReference { db.collection(Collections.bands) }
    static var users: CollectionReference { db.collection(Collections.users) }

    // MARK: - Creating
    static func create(user: User) {
        let dict = [Fields.name: user.name]
        let id = generateID(for: user)
        user.id = id

        users.document(id).setData(dict) { error in
            if let error = error {
                print("User could not be added to database. -", error.localizedDescription)
            } else {
                print("User successfully added.")
            }
        }
    }
    
    static func create(band: Band) {
        let id = generateID(for: band)
        band.id = id
        
        var dict = [String: Any]()
        dict[Fields.name] = band.name
        let timestamp = Timestamp(date: Date())
        dict[Fields.created] = timestamp
        dict[Fields.modified] = timestamp
        dict[Fields.index] = band.index
        
        bands.document(id).setData(dict) { error in
            if let error = error {
                print("Band could not be added to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func create(song: Song, in band: Band) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        let songID = generateID(for: song)
        song.id = songID
        
        var dict = [String: Any]()
        dict[Fields.text] = song.text
        let timestamp = Timestamp(date: Date())
        dict[Fields.created] = timestamp
        dict[Fields.modified] = timestamp
        
        bands.document(bandID).collection(Collections.songs).document(songID).setData(dict) { error in
            if let error = error {
                print("Song could not be added to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func create(list: List, in band: Band) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        let listID = generateID(for: list)
        list.id = listID
        
        var dict = [String: Any]()
        dict[Fields.name] = list.name
        let timestamp = Timestamp(date: Date())
        dict[Fields.created] = timestamp
        dict[Fields.modified] = timestamp
        dict[Fields.index] = list.index
        
        bands.document(bandID).collection(Collections.lists).document(listID).setData(dict) { error in
            if let error = error {
                print("Songlist could not be added to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    
    // MARK: - Deleting
    static func delete(user: User) {
        guard let id = user.id else { fatalError("User has no ID") }
        users.document(id).delete() { error in
            if let error = error {
                print("User could not be deleted from database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func delete(band: Band) {
        guard let id = band.id else { fatalError("Band has no ID") }
        bands.document(id).delete() { error in
            if let error = error {
                print("Band could not be deleted from database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
        // TODO: Subcollections should be deleted, too, but this is only possible via a cloud function (if at all). Maybe I can just leave the stuff there?
    }
    
    static func delete(song: Song, from band: Band) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        guard let songID = song.id else { fatalError("Song has no ID") }
        bands.document(bandID).collection(Collections.songs).document(songID).delete() { error in
            if let error = error {
                print("Song could not be deleted from database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
        // TODO: Handle playlists that use that song
    }
    
    static func delete(list: List, from band: Band) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        guard let listID = list.id else { fatalError("List has no ID") }
        bands.document(bandID).collection(Collections.lists).document(listID).delete() { error in
            if let error = error {
                print("List could not be deleted from database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    
    // MARK: - Renaming
    static func rename(user: User, to name: String) {
        guard let id = user.id else { fatalError("User has no ID") }
        var dict = [String: Any]()
        dict[Fields.name] = name
        dict[Fields.modified] = Timestamp(date: Date())
        users.document(id).setData(dict, merge: true) { error in
            if let error = error {
                print("User could not be renamed in database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func rename(band: Band, to name: String) {
        guard let id = band.id else { fatalError("Band has no ID") }
        var dict = [String: Any]()
        dict[Fields.name] = name
        dict[Fields.modified] = Timestamp(date: Date())
        bands.document(id).setData(dict, merge: true) { error in
            if let error = error {
                print("Band could not be renamed in database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func update(song: Song, in band: Band) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        guard let songID = song.id else { fatalError("Song has no ID") }
        
        var dict = [String: Any]()
        dict[Fields.text] = song.text
        dict[Fields.modified] = Timestamp(date: Date())
        
        bands.document(bandID).collection(Collections.songs).document(songID).setData(dict) { error in
            if let error = error {
                print("Song could not be changed in database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func rename(list: List, in band: Band, to name: String) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        guard let listID = list.id else { fatalError("List has no ID") }
        var dict = [String: Any]()
        dict[Fields.name] = name
        dict[Fields.modified] = Timestamp(date: Date())
        bands.document(bandID).collection(Collections.lists).document(listID).setData(dict, merge: true) { error in
            if let error = error {
                print("List could not be renamed in database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
        
    
    // MARK: - Reordering
    static func set(index: Int, for band: Band) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        bands.document(bandID).setData([Fields.index: index], merge: true) { error in
            if let error = error {
                print("List index could not be written to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func set(index: Int, for list: List, in band: Band) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        guard let listID = list.id else { fatalError("List has no ID") }
        bands.document(bandID).collection(Collections.lists).document(listID).setData([Fields.index: index], merge: true) { error in
            if let error = error {
                print("List index could not be written to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
    
    static func updateSongs(for list: List, in band: Band) {
        guard let bandID = band.id else { fatalError("Band has no ID") }
        guard let listID = list.id else { fatalError("List has no ID") }
        var dict = [String: SongID]()
        
        // Use the songID array to create a dictionary
        for (index, song) in list.songs.enumerated() {
            guard let songID = song.id else { fatalError("Song has no ID") }
            dict[String(index)] = songID
        }
        bands.document(bandID).collection(Collections.lists).document(listID).setData([Fields.songs: dict], merge: true) { error in
            if let error = error {
                print("SongIDs for list \(list.name) could not be written to database. -", error.localizedDescription)
            } else {
                print("Document successfully written.")
            }
        }
    }
}
    
// MARK: - Listeners
extension DBManager {
    static func listenForAuthState(onChange: @escaping (_ user: User) -> ()) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let userAuth = user else { print("No user logged in"); return }
            let name = userAuth.displayName ?? userAuth.email ?? userAuth.phoneNumber ?? "Unknown User"
            let id = userAuth.uid
            self.users.document(id).getDocument() { (document, error) in
                if let document = document, document.exists {
                    // TODO: I don't even use the document here but use name and id of userAuth. That may be fine, but then I don't need if let.
                    let user = User(id: id, name: name)
                    onChange(user)
                } else {
                    print("Document does not exist.", error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    static func listenForBands(with user: User, onChange: @escaping (_ bands: [Band]) -> ()) -> ListenerRegistration {
        // Needed by: OverviewVC (and later SettingsVC?)
        // Listen for bands the user is in
        guard let userID = user.id else { fatalError("User has no ID") }
        return bands.whereField("members.\(userID)", isGreaterThan: -1).addSnapshotListener() { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("The user's bands could not be fetched.", error?.localizedDescription ?? "")
                return
            }
            let bands = documents.map { makeBand(dict: $0.data(), id: $0.documentID) }
            // Songs and lists are not filled into the band objects here. Those are listened for seperately.

            onChange(bands)
        }
    }
    
    static func listenForLists(in band: Band, onChange: @escaping (_ lists: [List]) -> ()) -> ListenerRegistration {
        // Needed by OverviewVC
        guard let bandID = band.id else { fatalError("Band has no ID") }
        return bands.document(bandID).collection(Collections.lists).order(by: Fields.index).addSnapshotListener() { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("The band's lists could not be fetched.", error?.localizedDescription ?? "")
                return
            }
            let lists = documents.map { makeList(dict: $0.data(), id: $0.documentID, band: band) }
            onChange(lists)
        }
    }
    
    static func listenForSongs(in band: Band, onChange: @escaping (_ songs: [Song]) -> ()) -> ListenerRegistration {
        // Needed by AllSongsVC and PickVC
        guard let bandID = band.id else { fatalError("Band has no ID") }
        return bands.document(bandID).collection(Collections.songs).addSnapshotListener() { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("The band's songs could not be fetched.", error?.localizedDescription ?? "")
                return
            }
            let songs = documents.map { makeSong(dict: $0.data(), id: $0.documentID, band: band) }
            onChange(songs.sorted())
        }
    }
    
//    static func getSongsFromList(_ list: List, in band: Band, completion: @escaping (_ songs: [Song]) -> ()) {
//        guard let bandID = band.id else { fatalError("Band has no ID") }
//
//        // Make sure the songs are put in the right order. Async fetching tends to mix them up.
//        var songs = [Song](repeating: Song(), count: list.songs.count)
//
//        for (i, song) in list.songs.enumerated() {
//            guard let songID = song.id else { fatalError("Song has no ID") }
//            bands.document(bandID).collection(Collections.songs).document(songID).getDocument { document, error in
//                guard let document = document else {
//                    print("Song could not be fetched.", error?.localizedDescription ?? "")
//                    return
//                }
//                guard let data = document.data() else {
//                    print("Song has no data.")
//                    return
//                }
//                songs[i] = makeSong(dict: data, id: document.documentID, band: band)
//            }
//        }
//        completion(songs)
//    }
}


// MARK: - Helper Functions
extension DBManager {
    
//    static func generateDocumentID(type: DocumentType, name: String) -> String {
//        // Create date stamp
//        let formatter = DateFormatter()
//        formatter.dateFormat = "y-M-d H:m:s-SSSS"
//        let stamp = formatter.string(from: Date())
//
//        // Remove unallowed characters
//        let characterSet = CharacterSet(charactersIn: "./")
//        let components = name.components(separatedBy: characterSet)
//        let filteredName = components.joined(separator: "")
//
//        return type.rawValue + filteredName + stamp
//    }
    
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

    
    // Creating Band, Song and List instances from existing database entries
    static func makeBand(dict: [String: Any], id: BandID) -> Band {
        let name = dict[Fields.name] as? String ?? ""
        
        // TODO: The following two lines won't work. Instead, I would need two listeners to fill the band's songs and lists
//        let songs = dict[Collections.songs] as? [Song] ?? [Song]()
//        let lists = dict[Collections.lists] as? [List] ?? [List]()
        return Band(id: id, name: name)  //, songs: songs, lists: lists)
    }
    
    static func makeSong(dict: [String: Any], id: SongID, band: Band) -> Song {
        let text = dict[Fields.text] as? String ?? ""
        return Song(id: id, text: text)
    }
    
    static func makeList(dict: [String: Any], id: ListID, band: Band) -> List {
        // TODO: Is it good to crash if name or index cannot be fetched?
        let name = dict[Fields.name] as! String // ?? ""
        let index = dict[Fields.index] as! Int
        let songIDDict = dict[Fields.songs] as? [String: SongID] ?? [String: SongID]()
        
        var songs = [Song]()
        for (i, _) in songIDDict.enumerated() {
            if let songID = songIDDict[String(i)], let song = band.songs.first(where: { $0.id == songID }) {
                songs.append(song)
            }
        }
        
        return List(id: id, index: index, name: name, songs: songs)
    }
}
