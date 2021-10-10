//
//  AllSongsCell.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 09.11.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit

class AllSongsCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        self.textLabel?.text = "All Songs"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
