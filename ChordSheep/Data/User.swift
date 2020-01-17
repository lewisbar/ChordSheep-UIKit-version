//
//  User.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation

class User: Equatable, Comparable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
    
    
    var name = ""
    var uid = ""
    var transpositions = [String: Int]()    // [SongID: TranspositionLevel], example: [4jsflkj22434ksjf: -2]
    var notes = [String: String]()          // [SongID: Note], example: [240siljjfd290j: "Play this song slowly."]
    var zoomLevels = [String: Float]()      // [SongID: ZoomLevel], example: [984hf8ejefq84: 1.2432]
}
