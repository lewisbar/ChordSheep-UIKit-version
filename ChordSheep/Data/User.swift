//
//  User.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    var name: String
    var uid: UserID
    // var ref: DocumentReference?

//    var transpositions = [DocumentReference: Int]()    // [SongID: TranspositionLevel], example: [4jsflkj22434ksjf: -2]
//    var notes = [DocumentReference: String]()          // [SongID: Note], example: [240siljjfd290j: "Play this song slowly."]
//    var zoomLevels = [DocumentReference: Float]()      // [SongID: ZoomLevel], example: [984hf8ejefq84: 1.2432]
    
    init(name: String = "", uid: UserID = "", isNew: Bool) {
        self.name = name
        self.uid = uid
        if isNew  {
            DBManager.create(user: self)
        }
    }
}

extension User: Equatable, Comparable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
}
