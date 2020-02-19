//
//  SongPickVC.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 14.02.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit
import Firebase

protocol SongPickVCDelegate {
    func pickVCWasHidden()
}

class SongPickVC: UITableViewController {

    var delegate: SongPickVCDelegate?
    var db: Firestore!
    var snapshotListener: ListenerRegistration?
    var songs = [Song]()
    var songsRef: CollectionReference?
    
//    convenience init(songsRef: CollectionReference) {
//        self.init(style: .insetGrouped)
//        self.songsRef = songsRef
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = PaintCode.mediumDark
        
        tableView.register(SongCell.self, forCellReuseIdentifier: "songCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    func startListener() {
        snapshotListener = songsRef?.order(by: "title").addSnapshotListener() { snapshot, error in
            guard let documents = snapshot?.documents else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            self.songs = documents.map { Song(from: $0.data(), reference: $0.reference) }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
}
