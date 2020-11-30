//
//  User.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

typealias BandAccess = [BandID: Int]

class User: DatabaseStorable {
    var id: DocID?  // If nil, user has not been stored in database
    var name: String
    var bandAccess: BandAccess
    
//    var transpositions = [DocumentReference: Int]()    // [SongID: TranspositionLevel], example: [4jsflkj22434ksjf: -2]
//    var notes = [DocumentReference: String]()          // [SongID: Note], example: [240siljjfd290j: "Play this song slowly."]
//    var zoomLevels = [DocumentReference: Float]()      // [SongID: ZoomLevel], example: [984hf8ejefq84: 1.2432]
    
    init(id: UserID? = nil, name: String = "", bandAccess: BandAccess = BandAccess()) {
        self.id = id
        self.name = name
        self.bandAccess = bandAccess
    }
}

extension User: Equatable, Comparable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
}
