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
        
        snapshotListener = songlist.ref.addSnapshotListener() {snapshot, error in
            guard let snapshot = snapshot else {
                print(error!.localizedDescription)
                return
            }
            guard let songlist = snapshot.get("songs") as? [DocumentReference] else {
                print("No songs in this list.")
                return
            }
            // self.songlist = Songlist(from: data, reference: document.reference)

            for songRef in songlist {
                songRef.getDocument { document, error in
                    if let document = document, let data = document.data() {
                        self.songs.append(Song(from: data, reference: songRef))
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error!.localizedDescription)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pageVC?.didSelectSongAtRow(indexPath.row)
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

// MARK: Handle PageVC swipes
extension ListVC {
    func swipedToPosition(_ index: Int) {
        let path = IndexPath(row: index, section: 0)
        tableView.selectRow(at: path, animated: false, scrollPosition: .none) // .none does no scrolling in this method
        tableView.scrollToNearestSelectedRow(at: .none, animated: true) // because .none does no scrolling in selectRow(...)
    }
}

// MARK: Handle new songs and song updates
extension ListVC: AddVCDelegate {
    func receive(newSong song: Song) {
        guard let row = songs.index(of: song) else { return }
        let path = IndexPath(row: row, section: 0)
        tableView.insertRows(at: [path], with: .automatic)
        tableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        pageVC?.didSelectSongAtRow(row)
        pageVC?.editButton.isHidden = false  // In case the list has been empty
    }
}

extension ListVC: EditVCDelegate {
    func updateSong(with text: String) {
        // TODO: Do we still need this? The song should be directly updated in the database. This VC should have a listener installed to update the song via the database.
        guard let oldRow = selection else { print("No song selected"); return }
        let song = songs[oldRow]
        // song.text = text
        guard let newRow = songs.index(of: song) else { print("Song not in list"); return }

        let oldPath = IndexPath(row: oldRow, section: 0)
        let newPath = IndexPath(row: newRow, section: 0)
        tableView.reloadRows(at: [oldPath, newPath], with: .automatic)
        tableView.selectRow(at: newPath, animated: true, scrollPosition: .none)
        tableView.scrollToRow(at: newPath, at: .none, animated: true)

        pageVC?.didSelectSongAtRow(newRow)
    }
}

extension ListVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tapToDismissKeyboard.addTarget(self, action: #selector(dismissKeyboard))
        mainVC?.view.addGestureRecognizer(tapToDismissKeyboard)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        mainVC?.view.removeGestureRecognizer(tapToDismissKeyboard)
        if let text = textField.text {
            changeListTitle(to: text)
        }
    }
    
    @objc func changeListTitle(to newTitle: String) { }
}
