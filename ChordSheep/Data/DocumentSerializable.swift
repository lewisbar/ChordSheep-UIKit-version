//
//  DocumentSerializable.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 20.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import Foundation
import Firebase

protocol DocumentSerializable {
    init(from dict:[String: Any], reference: DocumentReference)
}
