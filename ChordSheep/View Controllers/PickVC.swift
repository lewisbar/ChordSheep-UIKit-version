//
//  PickVC.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.02.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

protocol PickVCDelegate {
    func pickVCWasHidden()
    func picked(songID: SongID)
}

class PickVC: UITableViewController, DatabaseDependent {
    let store: DBStore

    var delegate: PickVCDelegate?
    var snapshotListener: ListenerRegistration?
    // var songs = [Song]()
    var band: Band?
    
//    convenience init(songsRef: CollectionReference) {
//        self.init(style: .insetGrouped)
//        self.songsRef = songsRef
//    }
    
    init(band: Band? = nil, store: DBStore) {
        self.band = band
        self.store = store
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
    
    func startListener() {
        snapshotListener = DBManager.listenForAllSongs(in: band) { songs in
            self.songs = songs
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
//        snapshotListener = songsRef?.order(by: "title").addSnapshotListener() { snapshot, error in
//            guard let documents = snapshot?.documents else {
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//                return
//            }
//            self.songs = documents.map { Song(from: $0.data(), reference: $0.reference) }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
    }
    
    func stopListener() {
        snapshotListener?.remove()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        let song = songs[indexPath.row]
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = song.metadataDescription
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.picked(songID: songs[indexPath.row].id)
    }
}

extension PickVC: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let song = songs[indexPath.row]
        guard let textData = song.text.data(using: .utf8) else { return [] }
        let itemProvider = NSItemProvider(item: textData as NSData, typeIdentifier: kUTTypePlainText as String)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = song.id
        return [dragItem]
    }
}

extension PickVC: DatabaseDependent {
    func databaseDidChange(changedItems: [DatabaseStorable]) {
        // TODO
    }
}
