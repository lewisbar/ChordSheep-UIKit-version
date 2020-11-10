//
//  OverviewVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 21.03.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit
import Firebase

class OverviewVC: UITableViewController {

    var mainVC: MainVC!
    var db: Firestore!
    var snapshotListeners = [ListenerRegistration]()
    var user = User()
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
        
        // Listen for the currently logged in user
        // let authHandle =  // This was in front of the next line, but I don't need it right now. I'm leaving it here to remind me that it is possible to store the return value of addStateDidChangeListener, and I might need it in the future.
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let user = user else { print("No user logged in"); return }
            self.user.name = user.displayName ?? user.email ?? user.phoneNumber ?? "Unknown User"
            self.user.uid = user.uid
//            self.user.transpositions = user.transpositions
//            self.user.notes = user.notes
//            self.user.zoomLevels = user.zoomLevels
            
            // Listen to the bands the user is in
            let bandListener = self.db.collection("bands").whereField("members.\(user.uid)", isGreaterThan: -1).addSnapshotListener() { querySnapshot, error in
                guard let userBands = querySnapshot?.documents else {
                    print("The user's bands could not be fetched.")
                    return
                }
                
                // For every one of the user's bands, listen to the bands lists
                // self.bands.removeAll()
                self.bands = userBands.map { Band(name: $0.data()["name"] as! String, ref: $0.reference) }
                for band in self.bands {
                    // guard let bandName = band.data()["name"] as? String else { continue }
                    // var currentBand = Band(name: bandName, ref: band.reference)
                    // self.bands.append(currentBand)
                    
                    let listListener = band.ref.collection("lists").addSnapshotListener() { snapshot, error in
                        guard let snapshot = snapshot?.documents else {
                            print(error!.localizedDescription)
                            return
                        }
                        band.songlists = snapshot.map { Songlist(from: $0.data(), reference: $0.reference) }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
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
            return bands[section].songlists.count + 2
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
            cell?.textLabel?.text = bands[indexPath.section].songlists[indexPath.row - 2].title
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

    
    @objc func addSetlistButtonPressed() {
        // TODO: Implement adding setlists
        print("Adding setlists is not implemented yet.")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // guard let bandRef = currentBandRef, let band = currentBand else { return }
        let band = bands[indexPath.section]
        mainVC.currentBand = band
        
        switch indexPath.row {
        
        case 0:  // All Songs
            let songsRef = band.ref.collection("songs")
            let allSongsVC = AllSongsVC(mainVC: mainVC, pageVC: mainVC.pageVC, songsRef: songsRef)  // db.collection("bands/\(bandID)/songs"))
            mainVC.pageVC.songtableVC = allSongsVC
            navigationController?.pushViewController(allSongsVC, animated: true)
            
        case 1:  // New list
            let timestamp = Timestamp(date: Date())
            let date = timestamp.dateValue()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = formatter.string(from: date)
            let listRef = band.ref.collection("lists").addDocument(data: ["date": timestamp, "title": formattedDate])
            let songlist = Songlist(title: formattedDate, ref: listRef)
            
            let listVC = ListVC(mainVC: mainVC, pageVC: mainVC.pageVC, songlist: songlist, isNewList: true)
            mainVC.pageVC.songtableVC = listVC
            navigationController?.pushViewController(listVC, animated: true)
            
        default:
            let songlist = band.songlists[indexPath.row - 2]
            
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
        let band = bands[indexPath.section]

        if editingStyle == .delete {
            // Delete the row from the data source
            band.songlists[indexPath.row - 2].ref.delete() { err in
                if let err = err {
                    print("Error removing songlist: \(err)")
                } else {
                    print("Songlist successfully removed!")
                    // tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
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

}
