//
//  Band.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

// TODO: It could be that I don't need this class.

import Foundation
import Firebase

class Band {
    var name = ""
    // var id: String!
    var members = [String: Int]()
}


//extension Band: Equatable, Comparable {
//    static func == (lhs: Band, rhs: Band) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    static func < (lhs: Band, rhs: Band) -> Bool {
//        return lhs.name < rhs.name
//    }
//}
