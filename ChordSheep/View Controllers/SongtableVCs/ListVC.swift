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

    var list: List
    var isNewList = false
    override var songs: [Song] {
        return list.songs
    }

    init(store: DBStore, mainVC: MainVC, pageVC: PageVC, band: Band, list: List, isNewList: Bool = false) {
        self.list = list
        super.init(store: store, mainVC: mainVC, pageVC: pageVC, band: band)
        self.mainVC = mainVC
        self.pageVC = pageVC
        self.isNewList = isNewList
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dropDelegate = self
        header.text = list.name
        header.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        snapshotListener = DBManager.listenForList(list) { list in
//            self.songlist = list
//
//            DBManager.getSongsFromList(list) { songs in
//                self.songs = songs
//                DispatchQueue.main.async { self.tableView.reloadData() }
//            }
//        }
                        
        // isMovingToParent: Only true on first appearance, not when AddVC is dismissed, so after adding a song, that new song will be selected
        if isMovingToParent, self.songs.count > 0 {
            pageVC?.view.layoutSubviews() // Else, on first appearance, the song doesn't slide in all the way
            pageVC?.didSelectSongAtRow(0)
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            // pageVC?.editButton.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isNewList {
            header.becomeFirstResponder()
            header.selectAll(nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainVC?.hidePickVC()
    }
    
    @objc override func addButtonPressed() {
        if !addButton.isSelected {
            mainVC?.showPickVC(delegate: self)
            addButton.isSelected = true
        } else {
            mainVC?.hidePickVC()
            addButton.isSelected = false
        }
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
            store.remove(songAt: indexPath.row, from: list, in: band)
            tableView.deleteRows(at: [indexPath], with: .fade)

            // TODO: When you cancel a delete swipe at an index lower than the selection, the selection is still reduced by 1.
//            // For deleting the last song, the listener doesn't seem to fire, so I need to do this manually
//            if list.songs.count < 1 {
//                songs.removeAll()
//                tableView.reloadData()
//            }
        }
    }
    
    // TODO: Adding a song to an empty list sometimes adds an empty cell at the top, above the added song. Edit: Is that still the case?
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        print("movingRow")
        store.moveSong(fromIndex: fromIndexPath.row, toIndex: to.row, in: list, in: band)
        tableView.moveRow(at: fromIndexPath, to: to)
     }
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}


extension ListVC: PickVCDelegate {
    func pickVCWasHidden() {
        addButton.isSelected = false
    }
    
    func picked(song: Song) {
        store.add(song: song, in: list, in: band)
        // tableView.insertRows(at: <#T##[IndexPath]#>, with: <#T##UITableView.RowAnimation#>)
        // TODO: Restore selection
    }
}

extension ListVC: UITableViewDropDelegate {  // Note: Drag delegate stuff is in superclass (SongtableVC)
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        print("dropSessionDidUpdate")
        let isFromSameTable = tableView.hasActiveDrag  // (session.localDragSession?.localContext as? UITableView) === tableView
        // return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        return UITableViewDropProposal(operation: isFromSameTable ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        print("performDrop")
        let destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {  // Append at the end
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        for (row, item) in coordinator.items.enumerated() {
            let destinationIndexPathForItem = IndexPath(row: destinationIndexPath.row + row, section: destinationIndexPath.section)
            
            // 1. Local drags
            // This part is executed when dragging from PickVC; but not the "same table" part, because drags from the same table go through moveRow instead, at least for single items, but I don't get the table to accept multiple items, anyway.
            if let songID = item.dragItem.localObject as? SongID,
               let song = songs.first(where: { $0.id == songID }) {
                // Is the drag coming from same table?
                if let sourceIndexPath = item.sourceIndexPath {
                    store.moveSong(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPathForItem.row, in: list, in: band)
                    tableView.moveRow(at: sourceIndexPath, to: destinationIndexPathForItem)
                } else {
                    // Insert song in setlist
                    store.add(song: song, at: destinationIndexPathForItem.row, in: list, in: band)
                    tableView.insertRows(at: [destinationIndexPathForItem], with: .automatic)
                }
            }
                
            // 2. External drags
            else {
                coordinator.session.loadObjects(ofClass: NSString.self) { items in
                    for item in items {
                        if let text = item as? String,
                           let band = self.mainVC?.currentBand {
                            
                            // Add song to All Songs
                            let song = Song(text: text)
                            self.store.store(song: song, in: band)
                            
                            // Insert song in setlist
                            self.store.add(song: song, at: destinationIndexPath.row, in: self.list, in: band)
                            tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                        }
                    }
                }
            }
            // coordinator.drop(item.dragItem, toRowAt: destinationIndexPathForItem)  // Looks strange, maybe because changing the model automatically reloads the tableview.
        }
    }
    
//    func inserting(songRef: DocumentReference, into songRefs: [DocumentReference], at index: Int) -> [DocumentReference] {
//        var songRefs = songRefs
//
//        if songRefs.count > 0 {
//            songRefs.insert(songRef, at: index)
//        } else {
//            songRefs.append(songRef)
//        }
//        return songRefs
//    }
}


extension ListVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
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
        // Remove newlines from drops and pastes and limit to a reasonable length in case someone pastes a novel into the header
        if let newText = header.text?.components(separatedBy: .newlines).first {
            header.text = String(newText.prefix(30))
        }
        mainVC?.view.removeGestureRecognizer(tapToDismissKeyboard)
        if let text = textField.text {
            store.rename(list: list, to: text, in: band)
        }
    }
}
