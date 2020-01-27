//
//  Exporter.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 27.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation

struct Exporter {
    static func text(song: Song) -> String {
        return song.text  // Is this really necessary? Unneeded complexity.
    }
    
    // static func textFile(song: Song) -> ...
}
