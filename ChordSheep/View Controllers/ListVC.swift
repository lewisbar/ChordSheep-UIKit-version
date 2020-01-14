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

class ListVC: UITableViewController {

    weak var mainVC: MainVC?
    weak var pageVC: PageVC?
    var songs: [Song]? { return nil }
    var listTitle = ""
    var selection: Int? {
        return tableView.indexPathForSelectedRow?.row
    }
    let tapToDismissKeyboard = UITapGestureRecognizer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SongCell.self, forCellReuseIdentifier: "songCell")
        
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // isMovingToParent: Only true on first appearance, not when AddVC is dismissed, so after adding a song, that new song will be selected
        if isMovingToParent, let songs = self.songs, songs.count > 0 {
            pageVC?.view.layoutSubviews() // Else, on first appearance, the song doesn't slide in all the way
            pageVC?.didSelectSongAtRow(0)
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            pageVC?.editButton.isHidden = false
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        if let song = songs?[indexPath.row] {
            cell.textLabel?.text = song.title
            cell.detailTextLabel?.text = song.metadataDescription
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ButtonHeader(title: listTitle, target: self, selector: #selector(addButtonPressed))
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
        guard let row = songs?.index(of: song) else { return }
        let path = IndexPath(row: row, section: 0)
        tableView.insertRows(at: [path], with: .automatic)
        tableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        pageVC?.didSelectSongAtRow(row)
        pageVC?.editButton.isHidden = false  // In case the list has been empty
    }
}

extension ListVC: EditVCDelegate {
    func updateSong(with text: String) {
        guard let oldRow = selection else { print("No song selected"); return }
        guard let song = songs?[oldRow] else { print("Song doesn't exist"); return }
        song.text = text
        guard let newRow = songs?.index(of: song) else { print("Song not in list"); return }

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
