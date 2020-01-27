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
    var bandID = "bWKUThcaXl3RX9ElTELf"  // TODO: Don't hardcode
    var songlists = [Songlist]()
    var snapshotListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        tableView.register(ListCell.self, forCellReuseIdentifier: "listCell")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide Edit Button
        mainVC.pageVC.editButton.isHidden = true
        
        // Show no song
        mainVC.pageVC.setViewControllers([UIViewController()], direction: .reverse, animated: true)
        
        snapshotListener = db.collection("bands").document(bandID).collection("lists").addSnapshotListener() { snapshot, error in
            guard let snapshot = snapshot?.documents else {
                print(error!.localizedDescription)
                return
            }
            self.songlists = snapshot.map { Songlist(from: $0.data(), reference: $0.reference) }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        snapshotListener?.remove()
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: return number of lists in database
        return songlists.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "All Songs"
        default:
            cell.textLabel?.text = songlists[indexPath.row - 1].title
        }
        
        return cell
    }

    
    @objc func addSetlistButtonPressed() {
        // TODO: Implement adding setlists
        print("Adding setlists is not implemented yet.")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let allSongsVC = AllSongsVC(mainVC: mainVC, pageVC: mainVC.pageVC, songsRef: db.collection("bands/\(bandID)/songs"))
            mainVC.pageVC.songtableVC = allSongsVC
            navigationController?.pushViewController(allSongsVC, animated: true)
            return
        }
        let songlist = songlists[indexPath.row - 1]
        let listVC = ListVC(mainVC: mainVC, pageVC: mainVC.pageVC, songlist: songlist)
        mainVC.pageVC.songtableVC = listVC
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // "All Songs" filter must not be deleted
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

}
