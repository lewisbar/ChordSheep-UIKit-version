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
        self.init(style: .insetGrouped)
        self.mainVC = mainVC
        self.pageVC = pageVC
        self.songlist = songlist
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.text = songlist.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        snapshotListener = songlist.ref.addSnapshotListener() {snapshot, error in
            guard let songlistDict = snapshot?.data() else {
                print("Songs couldn't be read.")
                return
            }
            
            self.songlist = Songlist(from: songlistDict, reference: self.songlist.ref)
            
            // Make sure the songs are put in the right order. Async fetching tends to mix them up.
            self.songs = [Song](repeating: Song(with: ""), count: self.songlist.songRefs.count)
            for (i, songRef) in self.songlist.songRefs.enumerated() {
                songRef.getDocument { document, error in
                    guard let data = document?.data() else {
                        print(songRef.path)
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        return
                    }
                    self.songs[i] = Song(from: data, reference: songRef)
                    DispatchQueue.main.async {
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
            // pageVC?.editButton.isHidden = false
        }
    }
    
    @objc override func addButtonPressed() {
        mainVC.showPickVC()
    }
    
    
    // MARK: - Table view data source
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return ButtonHeader(title: songlist.title, target: self, selector: #selector(addButtonPressed))
//    }
    
    // TODO: When adding songs of reordering, maybe the easiest approach is to reinitialize the songlist using the songs array, giving every song the correct index for the map/dict.
    // I don't understand my own TODO anymore. I don't know if it's outdated.

    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
    

    // TODO: Implement blocks (like worship blocks) with titles. Uses those titles here
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return blocks[section].title
//    }
    
    // TODO: If last song is deleted, hide edit button?
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            songlist.songRefs.remove(at: indexPath.row)
            songlist.ref.updateData(["songs": songlist.songRefDict])
        }
    }
    
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
