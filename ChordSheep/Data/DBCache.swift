//
//  DBCache.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 26.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation

typealias DocID = String

protocol DatabaseStorable {
    var id: DocID? { get }
    var name: String { get set }
}
protocol DatabaseDependent {
    var cache: DBCache { get }
}

class DBCache {
    /* Offline representation of the whole database, that is, the bands the user is in, including their songs and lists. */
    private(set) var bands = [Band]()
    init(bands: [Band] = [Band]()) { self.bands = bands }
    
    func create(band: Band) {
        bands.append(band)
        DBManager.create(band: band)
    }
    func create(song: Song, in band: Band) {
        band.songs.append(song)
        DBManager.create(song: song, in: band)
    }
    func create(list: List, in band: Band) {
        band.lists.append(list)
        DBManager.create(list: list, in: band)
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
     -> I think right now I search all bands of all users across the world to find out in which one a particular user is. Maybe I should change the structure there. Not the band saves it users, but the other way around, the user has a dictionary "bandAccess" with bands and access levels. But what if a bandleader wants to see his members? That could be the time to do that other kind of search: Search all users for the bandID. Or, maybe better: The band AND the user both hold a reference to each other. Whenever a user is added to or removed from a band or his access level changes, both the user and the band must be updated. Yes, that's a good idea, because that's a seldom operation, and in that moment you already have a reference to both the user and the band, so you can use those to update both.
     */
}
