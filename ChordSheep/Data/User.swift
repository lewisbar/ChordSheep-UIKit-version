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
}
