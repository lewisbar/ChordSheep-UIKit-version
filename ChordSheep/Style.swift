//
//  Style.swift
//  Choly
//
//  Created by Lennart Wisbar on 13.02.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

struct Style {
    
    static func styledText(for text: String) -> NSAttributedString {
        let styledText = NSMutableAttributedString(string: text)
        
        for (range, part) in Style.findParts(in: text) {
            styledText.addAttributes(part.styles, range: range)
        }
        
        for range in Style.findChords(in: text) {
            styledText.addAttributes(chord.styles, range: range)
        }
        
        for range in Style.findAnnotations(in: text) {
            styledText.addAttributes(annotation.styles, range: range)
        }
        
        return styledText
    }
    
    
    // TODO: If there is text in the same line, but outside of the brackets, put the chords above that. You can have your chords inline, top, bottom, or even above each part. If a part contains no text, but only chords, the chords get the part color. Else, chords have a special chord color. EDIT: Is that a good idea? By now I think it's better to give all chords the same color, so you don't miss them when you're playing chords. Later, the user should be given the ability to choose some styling preferences.
    
    private struct Part {
        let keys: [String]
        let styles: [NSAttributedString.Key: Any]
    }
    
    private static let partTitle = Part(
        keys: [],
        styles: [NSAttributedString.Key.foregroundColor: UIColor.gray]
    )
    private static let chorus = Part(
        keys: ["Chorus", "Ch", "Chrs"],
        styles: [NSAttributedString.Key.foregroundColor: UIColor.yellow]
    )
    private static let verse = Part(
        keys: ["Verse", "Ve", "V", "Vrs", "Vrse", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"],
        styles: [NSAttributedString.Key.foregroundColor: UIColor.white]
    )
    private static let bridge = Part(
        keys: ["Bridge", "Br", "Brdg", "Brdge"],
        styles: [NSAttributedString.Key.foregroundColor: UIColor.green]
    )
    private static let preChorus = Part(
        keys: ["Pre-Chorus", "PC", "PreChorus", "PrChrs", "P"],
        styles: [NSAttributedString.Key.foregroundColor: UIColor.orange]
    )
    private static let annotation = Part(
        keys: [],
        styles: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
    )
    private static let chord = Part(
        keys: [],
        styles: [NSAttributedString.Key.font: UIFont(name: "Menlo", size: 17) ?? UIFont.monospacedDigitSystemFont(ofSize: 17, weight: UIFont.Weight.regular),
                 NSAttributedString.Key.foregroundColor: UIColor.red]
    )
    
    private static let normalParts = [chorus, verse, bridge, preChorus]
    

    private static func findAnnotations(in text: String) -> [NSRange]  {
        let pattern = "(\\([^\\(\\)]*\\))|(-{1,2}>.*)"
        let regex = try! NSRegularExpression(pattern: pattern)
        let searchRange = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: searchRange)
        return matches.map { $0.range }
    }
    private static func findParts(in text: String) -> [(NSRange, Part)] {
        var result = [(NSRange, Part)]()
        let matches = songPartTriggers(in: text)
        for i in 0..<matches.count {
            result.append((matches[i].range, partTitle))
            
            guard let partType = determinePartType(for: matches[i], in: text) else { continue }
            
            let partStart = matches[i].range.upperBound
            let partEnd = (i+1 < matches.count) ? matches[i+1].range.lowerBound : (text.endIndex.utf16Offset(in: text)) // for last item, take end of text as partEnd
            let partLength = partEnd - partStart
            let partRange = NSRange(location: partStart, length: partLength)
            result.append((partRange, partType))
        }
        return result
    }
    private static func findChords(in text: String) -> [NSRange] {
        let pattern = "\\[[^\\[\\]]*\\]"
        let regex = try! NSRegularExpression(pattern: pattern)
        let searchRange = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: searchRange)
        return matches.map { $0.range }
    }
    
    private static func songPartTriggers(in text: String) -> [NSTextCheckingResult] {
        let pattern = "(?i)(.+:)|(^\\d+(\\s|\\.|\n))"  // TODO: Remove \\s, so a verse can't be triggered by a digit with a whitespace behind it, so that the song "99 Luftballons" will work, for example?
        let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
        let searchRange = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: searchRange)
    }
    
    private static func determinePartType(for match: NSTextCheckingResult, in text: String) -> Part? {
        for part in normalParts {
            let matchedExpression = String(text[Range(match.range, in: text)!])
            for keyword in part.keys {
                if matchedExpression.starts(with: keyword) {
                    return part
                }
            }
        }
        return nil
    }
}

//extension UIColor {
//    static let csLight = UIColor.white
//    static let csMedium = UIColor(hue: 0.58, saturation: 0.50, brightness: 0.20, alpha: 1.00)
//    static let csMediumDark = UIColor(hue: 0.58, saturation: 1.00, brightness: 0.12, alpha: 1.00)
//    static let csDark = UIColor.black
//}
