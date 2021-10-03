//
//  DBCache.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 26.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

typealias DocID = String

protocol DatabaseStorable {
    var id: DocID? { get }
    var name: String { get set }
}
protocol DatabaseDependent: AnyObject {
    /* DatabaseDependent types should also subscribe to their store by calling store.subcribe(_:subscriberID:) and unsubcribe on deallocation at latest. */
    var store: DBStore { get }
    func databaseDidChange(changedItems: [DatabaseStorable])
}


class DBStore {
    /* Offline representation of the whole database, that is, the bands the user is in, including their songs and lists. */
    var user: User?
    private(set) var bands = [Band]()
    private var subscribers = [String: DatabaseDependent]()
    private var listeners = [ListenerRegistration]()

    
    
    init() { startListening() }
    
    deinit { stopListening() }
    
    
    // Manipulating objects in the database. To be called by ViewControllers that present the data to the user and let them edit it. In most cases, we just have to make the change in the database. Then the corresponding listener will take care of the rest.
    // Storing
    // In general, I want to first change the data locally and then I write them to the database. If I would instead only write to the database and then rely on the listeners to update my local data, I would always have to wait for the data to be updated. This would lead to strange misbehavior, for example when deleting a song in a tableview. ViewControllers must also update their interface directly instead of waiting for the listener callback. Otherwise, you could, for example, get an out-of-bounds error when deleting the last song if it's already been deleted in the model, but the view hasn't received the update yet.
    func store(user: User) {
        // TODO: Also set self.user to the user? Not sure, but I don't think so, because self.user must always be the currently logged in user as reported by the auth listener.
        DBManager.create(user: user)
    }
    func store(band: Band) {  // TODO: Not implemented in UI
        band.set(index: self.bands.count)
        self.bands.append(band)
        DBManager.create(band: band)
    }
    func store(song: Song, in band: Band) {
        band.add(song: song)
        DBManager.create(song: song, in: band)
    }
    func store(list: List, in band: Band) {
        band.insert(list: list, at: 0)
        DBManager.create(list: list, in: band)
    }
    func add(song: Song, at index: Int? = nil, in list: List, in band: Band) {
        if let index = index {
            list.insert(song: song, at: index)
        } else {
            list.append(song: song)
        }
        DBManager.updateSongs(for: list, in: band)
    }
    
    // Deleting
    func delete(user: User) {
        // TODO: How to delete that user locally?
        DBManager.delete(user: user)
    }
    func delete(band: Band) {
        bands.remove(at: band.index)
        for (i, band) in bands.enumerated() { band.set(index: i) }
        DBManager.delete(band: band)
    }
    func delete(song: Song, index: Int, from band: Band) {
        band.removeSong(at: index)
        DBManager.delete(song: song, from: band)
    }
    func delete(list: List, from band: Band) {
        band.removeList(at: list.index)
        for (i, list) in band.lists.enumerated() { list.set(index: i) }
        DBManager.delete(list: list, from: band)
    }
    func remove(songAt index: Int, from list: List, in band: Band) {
        list.removeSong(at: index)
        DBManager.updateSongs(for: list, in: band)
    }
    
    // Renaming
    func rename(user: User, to name: String) {
        user.name = name
        DBManager.rename(user: user, to: name)
    }
    func rename(band: Band, to name: String) {
        band.name = name
        DBManager.rename(band: band, to: name)
    }
    func retext(song: Song, in band: Band, with text: String) {
        song.set(text: text)
        DBManager.update(song: song, in: band)
    }
    func rename(list: List, to name: String, in band: Band) {
        list.name = name
        DBManager.rename(list: list, in: band, to: name)
    }
    
    // Reordering
    func moveBand(fromIndex: Int, toIndex: Int) {
        bands.moveElement(fromIndex: fromIndex, toIndex: toIndex)
        
        // Update indices
        for index in min(fromIndex, toIndex)...max(fromIndex, toIndex) {
            bands[index].set(index: index)
            DBManager.set(index: index, for: bands[index])
        }
    }
    func moveList(fromIndex: Int, toIndex: Int, in band: Band) {
        band.moveList(fromIndex: fromIndex, toIndex: toIndex)
        
        // Update indices
        for index in min(fromIndex, toIndex)...max(fromIndex, toIndex) {
            band.lists[index].set(index: index)
            DBManager.set(index: index, for: band.lists[index], in: band)
        }
    }
    func moveSong(fromIndex: Int, toIndex: Int, in list: List, in band: Band) {
        list.moveSong(fromIndex: fromIndex, toIndex: toIndex)
        DBManager.updateSongs(for: list, in: band)
    }
    
    private func id(for subscriber: DatabaseDependent) -> String {
        return String(UInt(bitPattern: ObjectIdentifier(subscriber)))
    }
    func subscribe(_ subscriber: DatabaseDependent) {
        subscribers[id(for: subscriber)] = subscriber
    }
    func unsubscribe(_ subscriber: DatabaseDependent) {
        subscribers.removeValue(forKey: id(for: subscriber))
    }
    
    func startListening() {
        // The listeners for auth, bands, and lists depend on each other and are therefore nested
        // Listen for the currently logged in user
        let _ = DBManager.listenForAuthState { user in
            self.user = user
            self.subscribers.forEach { $0.value.databaseDidChange(changedItems: [user]) }
            // for sub in self.subscribers { sub.databaseDidChange(changedItems: [user])}
            
            // Listen to the bands the user is in
            let bandListener = DBManager.listenForBands(with: user) { bands in
                self.bands = bands
                self.subscribers.forEach { $0.value.databaseDidChange(changedItems: bands) }
                // for sub in self.subscribers { sub.databaseDidChange(changedItems: bands) }
                
                // For every one of the user's bands, listen to the band's lists
                for (i, band) in self.bands.enumerated() {
                    let songListener = DBManager.listenForSongs(in: band) { songs in
                        band.set(songs: songs)
                        self.subscribers.forEach { $0.value.databaseDidChange(changedItems: songs) }
                        // for sub in self.subscribers { sub.databaseDidChange(changedItems: songs) }
                        
                        let listListener = DBManager.listenForLists(in: band) { lists in
                            self.bands[i].set(lists: lists)
                            self.subscribers.forEach { $0.value.databaseDidChange(changedItems: lists) }
                            // for sub in self.subscribers { sub.databaseDidChange(changedItems: lists)}
                            // DispatchQueue.main.async { self.tableView.reloadData() }
                        }
                        self.listeners.append(listListener)
                        print("Number of active listeners: \(self.listeners.count)")
                    }
                    self.listeners.append(songListener)
                }
            }
            self.listeners.append(bandListener)
        }
    }
    
    func stopListening() { for listener in listeners { listener.remove() } }
    
}

    /*
     Install listeners here? (tl;dr: YES!)
     To watch the whole database, I think I would need the following listeners
     - 1 for the login status (maybe not here?)
     - 1 for the bands the user is in (total: 1)
     - 1 for every band's lists (total: = number of bands, for example 2 or 3)
     - 1 for every band's songs (total: = number of bands, for example 2 or 3)
     -> Sum: 2 + (2 * bands.count) = around 2-7
     -> The user would have to be in more than 49 bands to exceed the limit of 100 listeners
     -> I should limit the number of bands for one user to 49 (or less to control db access rates which will eventually cost money; I think 20 bands would be more than enough)
     -> It seems not too much to listen to the whole database all the time.
     -> I think right now I search all bands of all users across the world to find out in which one a particular user is. Maybe I should change the structure there. Not the band saves its users, but the other way around, the user has a dictionary "bandAccess" with bands and access levels. But what if a bandleader wants to see his members? That could be the time to do that other kind of search: Search all users for the bandID. Or, maybe better: The band AND the user both hold a reference to each other. Whenever a user is added to or removed from a band or his access level changes, both the user and the band must be updated. Yes, that's a good idea, because that's a seldom operation, and in that moment you already have a reference to both the user and the band, so you can use those to update both.
     -> Update: Firebase works so efficiently, the speed only depends on the result, not on the number of documents to be searched. So I don't need the user to store a list of his bands.
     */
