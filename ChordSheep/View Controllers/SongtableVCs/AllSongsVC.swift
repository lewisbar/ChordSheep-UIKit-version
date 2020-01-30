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
            song.ref.delete()
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

}
