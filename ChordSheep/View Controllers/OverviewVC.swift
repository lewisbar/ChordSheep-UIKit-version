//
//  OverviewVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 21.03.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices  // for kUTTypePlainText for dragging

class OverviewVC: UITableViewController, UITableViewDragDelegate {
    var mainVC: MainVC!
    var db: Firestore!
    var snapshotListeners = [ListenerRegistration]()
    var user: User?
    var bands = [Band]()
    var closedSections = Set<Int>()
    let editButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        tableView.register(AllSongsCell.self, forCellReuseIdentifier: "allSongsCell")
        tableView.register(AddListCell.self, forCellReuseIdentifier: "addListCell")
        tableView.register(ListCell.self, forCellReuseIdentifier: "listCell")
        
        // Add a padding above the first section
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        
        tableView.backgroundColor = PaintCode.mediumDark
        
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true  // TODO: Do I need this? Enables intra-app drags for iPhone. I think I need it to be even able to start a drag.
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        editButton.setBackgroundImage(PaintCode.imageOfEditIcon, for: .normal)
        editButton.setBackgroundImage(PaintCode.imageOfEditIconActive, for: .selected)
        editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        
        // Make the Back button only be an arrow, without a title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        
        // loadData()
//        Importer.text("""
//Wege vor mir
//Samuel Harfst
//Key: F#m
//Capo: 2
//
//  Em        Em/D Cmaj7             Am
//1. So viele Wege liegen, Herr, vor mir
//Em        Em/D Cmaj7          Am
// So wenig Wege führen mich zu dir
//Em        Em/D    Cmaj7            Am
// So viele Wege versprechen mir das Glück
//    Em         Em/D     Cmaj7            Am
//Doch wohin ich gehe, da führt kein Weg zurück
//
//  Em       Em/D      Cmaj7          Am
//2. Große Gedanken verlaufen sich im Sand
//Em         Em/D         Cmaj7         Am
// Geben dem nächsten die Klinke in die Hand
//Em          Em/D         Cmaj7             Am
// Vergöttern Wissen, doch wissen nichts von Gott
//Em        Em/D       Cmaj7           Am
// Heute am Blühen und morgen schon verdorrt
//
//Refrain:
//Em              D/F#  G6             Am7          Em
//Herr, an deinem Segen ist mir mehr gelegen als an Gold
//           D              Cmaj7Bm7
//Auf deinen Wegen will ich gehn
//Em              D     Cmaj7          Bm7          Em
//Herr, an deinen Wegen ist mir mehr gelegen als an Gold
//           D              Cmaj7Bm7
//Mit deinem Segen will ich gehn
//""", bandID: bandID)
    }
    
//    func loadData() {
//        db.collection("bands").document(bandID).collection("lists").getDocuments() {
//            querySnapshot, error in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            self.songlists = querySnapshot!.documents.compactMap({ Songlist(dictionary: $0.data()) })
//            print(self.songlists.count)
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
    
    @objc func editButtonPressed() {
        if !tableView.isEditing {
            tableView.setEditing(true, animated: true)
            editButton.isSelected = true
        } else {
            tableView.setEditing(false, animated: true)
            editButton.isSelected = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        // Hide Song Edit Button
        // mainVC.pageVC.editButton.isHidden = true
        
        // Show no song
        mainVC.pageVC.setViewControllers([UIViewController()], direction: .reverse, animated: true)
        
        // The listeners for auth, bands, and lists depend on each other and are therefore nested
        // Listen for the currently logged in user
        let _ = DBManager.listenForAuthState { user in
            self.user = user
            
            // Listen to the bands the user is in
            let bandListener = DBManager.listenForBands(with: user.uid) { bands in
                self.bands = bands
                
                // For every one of the user's bands, listen to the bands lists
                for (i, band) in self.bands.enumerated() {
                    let listListener = DBManager.listenForLists(in: band) { lists in
                        self.bands[i].lists = lists
                        DispatchQueue.main.async { self.tableView.reloadData() }
                    }
                    self.snapshotListeners.append(listListener)
                }
            }
            self.snapshotListeners.append(bandListener)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for snapshotListener in snapshotListeners {
            snapshotListener.remove()
        }
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return bands.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !closedSections.contains(section) {
            return bands[section].lists.count + 2
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?

        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "allSongsCell", for: indexPath)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "addListCell", for: indexPath)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
            cell?.textLabel?.text = bands[indexPath.section].lists[indexPath.row - 2].title
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton()
        button.setTitle(bands[section].name, for: .normal)
        button.contentEdgeInsets.top = 10
        button.contentEdgeInsets.bottom = 10
        button.backgroundColor = PaintCode.medium
        button.layer.cornerRadius = 5
        button.tag = section
        button.addTarget(self, action: #selector(toggleOpenSection(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func toggleOpenSection(sender: UIButton) {
        if closedSections.contains(sender.tag) {
            closedSections.remove(sender.tag)
        } else {
            closedSections.insert(sender.tag)
        }
        tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
    }

    
//    @objc func addSetlistButtonPressed() {
//        // TODO: Implement adding setlists
//        print("Adding setlists is not implemented yet.")
//    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // guard let bandRef = currentBandRef, let band = currentBand else { return }
        let band = bands[indexPath.section]
        mainVC.currentBand = band
        
        switch indexPath.row {
        
        case 0:  // All Songs
            let allSongsVC = AllSongsVC(mainVC: mainVC, pageVC: mainVC.pageVC, band: band)  // db.collection("bands/\(bandID)/songs"))
            mainVC.pageVC.songtableVC = allSongsVC
            navigationController?.pushViewController(allSongsVC, animated: true)
            
        case 1:  // New list
            let timestamp = Timestamp(date: Date())
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = formatter.string(from: timestamp.dateValue())
            
            let newList = bands[indexPath.section].createList(title: formattedDate, timestamp: timestamp)
            
            let listVC = ListVC(mainVC: self.mainVC, pageVC: self.mainVC.pageVC, songlist: newList, isNewList: true)
            self.mainVC.pageVC.songtableVC = listVC
            self.navigationController?.pushViewController(listVC, animated: true)
            
        default:
            let songlist = band.lists[indexPath.row - 2]
            
            let listVC = ListVC(mainVC: mainVC, pageVC: mainVC.pageVC, songlist: songlist)
            mainVC.pageVC.songtableVC = listVC
            navigationController?.pushViewController(listVC, animated: true)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // "All Songs" filter and "New Song" cell must not be deleted
        if indexPath.row <= 1 {
            return false
        }
        return true
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            bands[indexPath.section].delete(list: bands[indexPath.section].lists[indexPath.row - 2])
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    
    // MARK: Reordering of single items
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.row >= 2 else { return [] }
        let songlist = bands[indexPath.section].lists[indexPath.row - 2]
        var textForExport = songlist.title + "\n"
        
        DBManager.getSongsFromList(songlist) { songs in
            let titles = songs.map { $0.title }
            textForExport = titles.joined(separator: "\n")
            // TODO: This doesn't work as the method returns before this task is completed.
        }

        var itemProvider = NSItemProvider()  // Fallback in case the next line cannot convert to data. Just use an empty item provider.
        if let textData = textForExport.data(using: .utf8) {
            itemProvider = NSItemProvider(item: textData as NSData, typeIdentifier: kUTTypePlainText as String)
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = songlist.id
        return [dragItem]
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row >= 2  // Don't allow All Songs and New List to be moved
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section || proposedDestinationIndexPath.row < 2 {  // Trying to drag to a different section or into the protected area? Back to source.
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    
    // TODO: Sometimes a list doesn't want to get dropped, I think when you do two drags too quickly after one another, then the list is not fully updated yet. Maybe I can find some kind of solution for that.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.section == destinationIndexPath.section,
              destinationIndexPath.row >= 2 else { return }
        
        let oldIndex = sourceIndexPath.row - 2  // -2 because there are All Songs and New List cells at the top of the table
        let newIndex = destinationIndexPath.row - 2
        
        // Update the lists indices
        bands[sourceIndexPath.section].moveList(fromIndex: oldIndex, toIndex: newIndex)
    }
}

/*
extension OverviewVC: UITableViewDropDelegate {
    // "Local drags with one item go through the existing `tableView(_:moveRowAt:to:)` method on the data source." (https://developer.apple.com/documentation/uikit/drag_and_drop/adopting_drag_and_drop_in_a_table_view)
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return false  // session.canLoadObjects(ofClass: NSString.self)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        let isFromSameTable = (session.localDragSession?.localContext as? UITableView) === tableView
        return UITableViewDropProposal(operation: isFromSameTable ? .move : .cancel, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let sourceIndexPath = coordinator.items[0].sourceIndexPath else { return }
        
        let destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {  // meaning the drop location is at a specific index path, not just on an empty area on the table view
            guard indexPath.section == sourceIndexPath.section else { return }  // Only allow drops from the same section
            destinationIndexPath = indexPath
        } else {  // Append at the end
            // let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: sourceIndexPath.section)
            destinationIndexPath = IndexPath(row: row, section: sourceIndexPath.section)
        }
        
        for (row, item) in coordinator.items.enumerated() {
            let destinationIndexPathForItem = IndexPath(row: destinationIndexPath.row + row, section: destinationIndexPath.section)
            
            // Accepts only local drops
            if let listRef = item.dragItem.localObject as? DocumentReference {
                let band = bands[destinationIndexPathForItem.section]
                
                listRef.setData(["index": destinationIndexPathForItem.row - 2], merge: true)
                
                // Update the other lists' indices so the new list can take its place at the top
                for list in band.songlists {
                    if list.index > destinationIndexPathForItem.row {
                        let newIndex = list.index + 1
                        list.ref.setData(["index": newIndex], merge: true)
                    }
                }
            }
            // coordinator.drop(item.dragItem, toRowAt: destinationIndexPathForItem)  // Looks strange, maybe because changing the model automatically reloads the tableview.
        }
    }
    
//    func inserting(songRef: DocumentReference, into songlist: Songlist, at index: Int) -> Songlist {
//        var songlist = songlist
//
//        if songlist.songRefs.count > 0 {
//            songlist.songRefs.insert(songRef, at: index)
//        } else {
//            songlist.songRefs.append(songRef)
//        }
//        return songlist
//    }
}

*/
