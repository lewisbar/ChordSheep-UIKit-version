//
//  Songlist.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation

class Songlist: Equatable, Comparable {
    static func == (lhs: Songlist, rhs: Songlist) -> Bool {
        return (lhs.title == rhs.title) &&
            (lhs.songs == rhs.songs) &&
            (lhs.date == rhs.date)
    }
    
    static func < (lhs: Songlist, rhs: Songlist) -> Bool {
        return lhs.title < rhs.title
    }
    
    var title = ""
    var songs = [Song]()
    var date = Date()
}
