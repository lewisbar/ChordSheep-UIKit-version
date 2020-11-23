//
//  Song.swift
//  Choly
//
//  Created by Lennart Wisbar on 14.02.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

struct Song {
    
    // TODO: Create my own data types for key and signature?
    let bandID: String
    let id: String
    let timestamp: Timestamp
    
    var text = "" {
        didSet {
            evaluateText()
            DBManager.update(song: self)
        }
    }
    var title = ""
    var artist: String?
    var key: String?
    var tempo: Int?
    var signature: String?
    var body: String?
    
    
    // Compose a summary of all meta data for the detail label in the songlist
    var metadataDescription: String {
        var description = ""
        if let key = key {
            description += key + "  "
        }
        if let artist = artist {
            description += artist + "  "
        }
        if let tempo = tempo {
            description += String(tempo) + "  "
        }
        if let signature = signature {
            description += signature
        }
        return description.trimmingCharacters(in: .whitespaces)
    }
    
    
    init(text: String, id: SongID, bandID: BandID, timestamp: Timestamp) {
        self.text = text
        self.id = id
        self.bandID = bandID
        self.timestamp = timestamp
        evaluateText()
    }
    
    enum Key: String {
        case c = "C"
        case cMinor = "Cm"
        case cSharp = "C#"
        case cSharpMinor = "C#m"
        case dFlat = "Db"
        case dFlatMinor = "Dbm"
        case d = "D"
        case dMinor = "Dm"
        case dSharp = "D#"
        case dSharpMinor = "D#m"
        case eFlat = "Eb"
        case eFlatMinor = "Ebm"
        case e = "E"
        case eMinor = "Em"
        case f = "F"
        case fMinor = "Fm"
        case fSharp = "F#"
        case fSharpMinor = "F#m"
        case gFlat = "Gb"
        case gFlatMinor = "Gbm"
        case g = "G"
        case gMinor = "Gm"
        case gSharp = "G#"
        case gSharpMinor = "G#m"
        case aFlat = "Ab"
        case aFlatMinor = "Abm"
        case a = "A"
        case aMinor = "Am"
        case aSharp = "A#"
        case aSharpMinor = "A#m"
        case bFlat = "Bb"
        case bFlatMinor = "Bbm"
        case b = "B"
        case bMinor = "Bm"
        
        static func key(from expression: String) -> String? {
            switch expression {
            case "c", "cmaj", "cmajor": return Key.c.rawValue
            case "cm", "cmin", "cminor": return Key.cMinor.rawValue
            case "c#", "c#maj", "c#major": return Key.cSharp.rawValue
            case "c#m", "c#min", "c#minor": return Key.cSharpMinor.rawValue
            case "db", "dbmaj", "dbmajor": return Key.dFlat.rawValue
            case "dbm", "dbmin", "dbminor": return Key.dFlatMinor.rawValue
            case "d", "dmaj", "dmajor": return Key.d.rawValue
            case "dm", "dmin", "dminor": return Key.dMinor.rawValue
            case "d#", "d#maj", "d#major": return Key.dSharp.rawValue
            case "d#m", "d#min", "d#minor": return Key.dSharpMinor.rawValue
            case "eb", "ebmaj", "ebmajor": return Key.eFlat.rawValue
            case "ebm", "ebmin", "ebminor": return Key.eFlatMinor.rawValue
            case "e", "emaj", "emajor": return Key.e.rawValue
            case "em", "emin", "eminor": return Key.eMinor.rawValue
            case "f", "fmaj", "fmajor": return Key.f.rawValue
            case "fm", "fmin", "fminor": return Key.fMinor.rawValue
            case "f#", "f#maj", "f#major": return Key.fSharp.rawValue
            case "f#m", "f#min", "f#minor": return Key.fSharpMinor.rawValue
            case "gb", "gbmaj", "gbmajor": return Key.gFlat.rawValue
            case "gbm", "gbmin", "gbminor": return Key.gFlatMinor.rawValue
            case "g", "gmaj", "gmajor": return Key.g.rawValue
            case "gm", "gmin", "gminor": return Key.gMinor.rawValue
            case "g#", "g#maj", "g#major": return Key.gSharp.rawValue
            case "g#m", "g#min", "g#minor": return Key.gSharpMinor.rawValue
            case "ab", "abmaj", "abmajor": return Key.aFlat.rawValue
            case "abm", "abmin", "abminor": return Key.aFlatMinor.rawValue
            case "a", "amaj", "amajor": return Key.a.rawValue
            case "am", "amin", "aminor": return Key.aMinor.rawValue
            case "a#", "a#maj", "a#major": return Key.aSharp.rawValue
            case "a#m", "a#min", "a#minor": return Key.aSharpMinor.rawValue
            case "bb", "bbmaj", "bbmajor": return Key.bFlat.rawValue
            case "bbm", "bbmin", "bbminor": return Key.bFlatMinor.rawValue
            case "b", "bmaj", "bmajor": return Key.b.rawValue
            case "bm", "bmin", "bminor": return Key.bMinor.rawValue
            default: return nil
            }
        }
    }
    
    mutating func evaluateText() {
        let lines = text.components(separatedBy: .newlines)
        var lineIndex = -1
        
        for line in lines {
            lineIndex += 1
            
            // First and second line return title and artist without the need for a tag
            guard line.contains(":") else {
                if lineIndex == 0 {
                    title = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    continue
                }
                else if lineIndex == 1 {
                    artist = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    continue
                }
                else {
                    body = lines[lineIndex..<lines.endIndex].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    return
                }
            }
            
            // Separate tag from value
            let splitLine = line.split(separator: ":")
            guard let potentialTag = splitLine.first?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                let value = splitLine.last?.trimmingCharacters(in: .whitespacesAndNewlines)
                else {
                    body = lines[lineIndex..<lines.endIndex].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    return
            }
            
            // Get properties from tags
            switch potentialTag {
            case "title", "t":
                title = value
            case "artist", "subtitle", "st":
                artist = value
            case "key", "k":
                if let key = Key.key(from: value.lowercased()) {
                    self.key = key
                }
            case "tempo", "bpm":
                if var t = Int(value) {
                    
                    if t < 30 { t = 30 }
                    else if t > 360 { t = 360 }
                    
                    tempo = t
                }
            case "signature", "sign":
                if ["2/4", "3/4", "4/4", "6/8", "5/4", "7/4"].contains(value) {
                    signature = value
                }
            default:
                body = lines[lineIndex..<lines.endIndex].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                return
            }
        }
    }
    
    func delete() {
        // Delete from database.
        DBManager.delete(song: self, from: bandID)
    }
}


//extension Song {
//    init(from dict: [String: Any], reference: DocumentReference) {
//        self.text = dict["text"] as? String ?? ""
//        self.title = dict["title"] as? String ?? ""
//        self.artist = dict["artist"] as? String
//        self.key = dict["key"] as? String
//        self.tempo = dict["tempo"] as? Int
//        self.signature = dict["signature"] as? String
//        self.body = dict["body"] as? String
//        self.ref = reference
//    }
//    
//    var dict: [String: Any] {
//        var dict: [String: Any] = [
//            "text": self.text,
//            "title": self.title,
//        ]
//        if let artist = self.artist {
//            dict["artist"] = artist
//        }
//        if let key = self.key {
//            dict["key"] = key
//        }
//        if let tempo = self.tempo {
//            dict["tempo"] = tempo
//        }
//        if let signature = self.signature {
//            dict["signature"] = signature
//        }
//        if let body = self.body {
//            dict["body"] = body
//        }
//        return dict
//    }
//}


extension Song: Equatable, Comparable {
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.text == rhs.text
    }
    
    static func < (lhs: Song, rhs: Song) -> Bool {
        return lhs.text < rhs.text
    }
}
