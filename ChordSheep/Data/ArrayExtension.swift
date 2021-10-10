//
//  ArrayExtension.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 23.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation

extension Array {
    mutating func moveElement(fromIndex: Int, toIndex: Int) {
        guard fromIndex != toIndex else { return }
        if abs(fromIndex - toIndex) == 1 { self.swapAt(fromIndex, toIndex) }
        self.insert(self.remove(at: fromIndex), at: toIndex)
    }
}
