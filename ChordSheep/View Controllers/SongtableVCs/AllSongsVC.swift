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
    
    var songsRef: CollectionReference!
    
    convenience init(mainVC: MainVC, pageVC: PageVC, songsRef: CollectionReference) {
        self.init(style: .insetGrouped)
        self.mainVC = mainVC
        self.pageVC = pageVC
        self.songsRef = songsRef
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.text = "All Songs"
        header.isUserInteractionEnabled = false
        tableView.dropDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        snapshotListener = songsRef.order(by: "title").addSnapshotListener() {snapshot, error in
            guard let documents = snapshot?.documents else {
                print(error!.localizedDescription)
                return
            }
            self.songs = documents.map { Song(from: $0.data(), reference: $0.reference) }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc override func addButtonPressed() {
        let addVC = AddVC()
        addVC.delegate = self
        addVC.modalPresentationStyle = .fullScreen
        self.present(addVC, animated: true)
    }

    // MARK: - Table view data source


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = self.songs[indexPath.row]
            song.ref?.delete()
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            // TODO: Deletion must be handled in setlists that use the deleted song.
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     */
    
    override func receive(newSong song: Song) {
        // Add song to database
        songsRef.addDocument(data: song.dict)
        
        //        guard let row = songs.index(of: song) else { return }
        //        let path = IndexPath(row: row, section: 0)
        //        tableView.insertRows(at: [path], with: .automatic)
        //        tableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        //        pageVC?.didSelectSongAtRow(row)
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
                    self.receive(newSong: Song(with: text))
                }
            }
        }
    }
}
