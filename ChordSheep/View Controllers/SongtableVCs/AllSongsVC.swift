//
//  AllSongsVC.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 22.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit
import Firebase

class AllSongsVC: SongtableVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.text = "All Songs"
        header.isUserInteractionEnabled = false
        tableView.dropDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The IndexPath could change if the title has been edited, therefore we must find the song itself. The first occurrence is also the only one in "All Songs".
        guard let song = storedSelectedSong else { return }
        let rowToBeSelected = self.songs.firstIndex(where: { $0.id == song.id }) ?? 0
        let indexPathToBeSelected = IndexPath(row: rowToBeSelected, section: 0)
        tableView.selectRow(at: indexPathToBeSelected, animated: true, scrollPosition: .none)
        pageVC?.didSelectSongAtRow(indexPathToBeSelected.row)
    }
    
    @objc override func addButtonPressed() {
        let addVC = AddVC(store: store, band: band)
        addVC.modalPresentationStyle = .fullScreen
        self.present(addVC, animated: true)
    }
    
    
    // MARK: - Table view data source
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = self.songs[indexPath.row]
            store.delete(song: song, from: band)
            // band.delete(song: song)
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            // TODO: Deletion must be handled in setlists that use the deleted song.
        }
    }
}

extension AllSongsVC: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        // Don't accept in-app drags into the All Songs list (except maybe later from other bands), because this would lead to duplicate songs
        return session.localDragSession == nil &&
            session.canLoadObjects(ofClass: NSString.self)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .copy, intent: .unspecified)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        for item in coordinator.items {
            item.dragItem.itemProvider.loadObject(ofClass: NSString.self) { (provider, error) in
                if let text = provider as? String {
                    let song = Song(text: text)
                    self.store.store(song: song, in: self.band)
                    // self.receive(newText: text)
                }
            }
        }
    }
}
