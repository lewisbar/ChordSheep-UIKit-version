//
//  SongCell.swift
//  Choly
//
//  Created by Lennart Wisbar on 05.04.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class SongCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.numberOfLines = 0
        // detailTextLabel?.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
