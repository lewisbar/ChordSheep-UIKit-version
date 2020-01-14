//
//  Band.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation

class Band: Equatable, Comparable {
    static func == (lhs: Band, rhs: Band) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Band, rhs: Band) -> Bool {
        return lhs.name < rhs.name
    }
    
    
    var name = ""
    var id: String!
}
