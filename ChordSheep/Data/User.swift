//
//  User.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

class User: DatabaseStorable {
    var id: DocID?
    var name: String
    
    // var ref: DocumentReference?

//    var transpositions = [DocumentReference: Int]()    // [SongID: TranspositionLevel], example: [4jsflkj22434ksjf: -2]
//    var notes = [DocumentReference: String]()          // [SongID: Note], example: [240siljjfd290j: "Play this song slowly."]
//    var zoomLevels = [DocumentReference: Float]()      // [SongID: ZoomLevel], example: [984hf8ejefq84: 1.2432]
    
    init(name: String = "", id: UserID = "", isNew: Bool) {
        self.name = name
        self.id = id
        if isNew  {
            DBManager.create(user: self)
        }
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
