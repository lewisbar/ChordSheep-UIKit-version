//
//  SongtableVC.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 22.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit
import Firebase

class SongtableVC: UITableViewController, AddVCDelegate, EditVCDelegate {

    weak var mainVC: MainVC!
    weak var pageVC: PageVC!
    var db: Firestore!
    var snapshotListener: ListenerRegistration?
    var songs = [Song]()
    var selection: Int? {
        return tableView.indexPathForSelectedRow?.row
    }
    let tapToDismissKeyboard = UITapGestureRecognizer()
    let header: UILabel = {
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        header.font = UIFont.systemFont(ofSize: 24)
        header.textAlignment = .center
        header.adjustsFontSizeToFitWidth = true
        return header
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .csMediumDark
        
        db = Firestore.firestore()

        tableView.register(SongCell.self, forCellReuseIdentifier: "songCell")
        self.clearsSelectionOnViewWillAppear = false
        
        let addButton = UIBarButtonItem(image: PaintCode.imageOfPlusIcon, style: .plain, target: self, action: #selector(addButtonPressed))
        let editButton = UIBarButtonItem(image: PaintCode.imageOfEditIcon, style: .plain, target: self, action: #selector(editButtonPressed))
        navigationItem.rightBarButtonItems = [editButton, addButton]
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        tableView.tableHeaderView = header  // Subclasses can set header.text to set the title
    }
    
    @objc func addButtonPressed() {
        // Must be implemented by subclasses
    }
    
    @objc func editButtonPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Subclasses should add a snapshotListener in viewWillAppear
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
        pageVC?.didSelectSongAtRow(indexPath.row)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - Handle new songs and song updates
    func receive(newSong song: Song) {
        // Implement in subclass
    }
    
    func updateSong(with text: String) {
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

// MARK: Handle PageVC swipes
extension SongtableVC {
    func swipedToPosition(_ index: Int) {
        let path = IndexPath(row: index, section: 0)
        tableView.selectRow(at: path, animated: false, scrollPosition: .none) // .none does no scrolling in this method
        tableView.scrollToNearestSelectedRow(at: .none, animated: true) // because .none does no scrolling in selectRow(...)
    }
}


extension SongtableVC: UITextFieldDelegate {
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
