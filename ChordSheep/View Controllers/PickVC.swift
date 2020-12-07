//
//  PickVC.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.02.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol PickVCDelegate {
    func pickVCWasHidden()
    func picked(song: Song)
}

class PickVC: UITableViewController {
    let store: DBStore

    var delegate: PickVCDelegate?
    var band: Band?
    
    
    init(store: DBStore, band: Band? = nil) {
        self.store = store
        self.band = band
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = PaintCode.mediumDark
        
        tableView.register(SongCell.self, forCellReuseIdentifier: "songCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return band?.songs.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let band = band else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        let song = band.songs[indexPath.row]
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.metadataDescription
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let band = band else { return }
        delegate?.picked(song: band.songs[indexPath.row])
    }
}

extension PickVC: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let band = band else { return [UIDragItem]() }
        let song = band.songs[indexPath.row]
        guard let textData = song.text.data(using: .utf8) else { return [] }
        let itemProvider = NSItemProvider(item: textData as NSData, typeIdentifier: kUTTypePlainText as String)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = song.id
        return [dragItem]
    }
}

extension PickVC: DatabaseDependent {
    func databaseDidChange(changedItems: [DatabaseStorable]) {
        tableView.reloadData()
        // TODO: Surround this with DispatchQueue.main.async?
    }
}
