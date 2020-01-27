//
//  ListVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 05.04.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit
import Firebase

//protocol ListVCDelegate: AnyObject {
//    func didSelectSongAtRow(_ index: Int)
//}

class ListVC: SongtableVC {

    var songlist: Songlist!

    convenience init(mainVC: MainVC, pageVC: PageVC, songlist: Songlist) {
        self.init()
        self.mainVC = mainVC
        self.pageVC = pageVC
        self.songlist = songlist
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        snapshotListener = songlist.ref.collection("songs").addSnapshotListener() {snapshot, error in
            guard let documents = snapshot?.documents else {
                print(error!.localizedDescription)
                return
            }
            guard let songRefs = (documents.map { $0["songRef"] } as? [DocumentReference]) else { print("Songs couldn't be read.")
                return
            }
            
            for songRef in songRefs {
                songRef.getDocument { document, error in
                    guard let data = document?.data() else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    self.songs.append(Song(from: data, reference: songRef))
                    DispatchQueue.main.async {
                        // self.tableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .automatic)  // TODO: Try to only reload one row. This line doesn't work.
                        self.tableView.reloadData()
                    }
                }
            }
        }
                        
        // isMovingToParent: Only true on first appearance, not when AddVC is dismissed, so after adding a song, that new song will be selected
        if isMovingToParent, self.songs.count > 0 {
            pageVC?.view.layoutSubviews() // Else, on first appearance, the song doesn't slide in all the way
            pageVC?.didSelectSongAtRow(0)
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            pageVC?.editButton.isHidden = false
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ButtonHeader(title: songlist.title, target: self, selector: #selector(addButtonPressed))
    }
    
    @objc func addButtonPressed() {
        let addVC = AddVC()
        addVC.delegate = self
        self.present(addVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    

    
    
    // TODO: Deleting songs. If last song is deleted, hide edit button
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
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
    
}
