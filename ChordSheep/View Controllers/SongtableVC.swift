//
//  SongtableVC.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 22.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class SongtableVC: UITableViewController, DatabaseDependent {
    var store: DBStore
    
    weak var mainVC: MainVC?
    weak var pageVC: PageVC?
    var band: Band
    var songs: [Song] {
        return band.songs
    }
    var selection: Int? {
        return tableView.indexPathForSelectedRow?.row
    }
    
    
    // For remembering the selection in case it is removed, for example after editing mode
    var storedSelection: IndexPath?
    var storedSelectedSong: Song?

    let tapToDismissKeyboard = UITapGestureRecognizer()
    let header: UITextField = {
        let header = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        header.font = UIFont.systemFont(ofSize: 24)
        header.textAlignment = .center
        header.adjustsFontSizeToFitWidth = true
        header.textColor = PaintCode.light
        header.spellCheckingType = .no
        header.autocapitalizationType = .words
        return header
    }()
    let editButton = UIButton(type: .custom)
    let addButton = UIButton(type: .custom)
    let editSongButton = UIButton(type: .custom)
    
    init(store: DBStore, mainVC: MainVC, pageVC: PageVC, band: Band) {
        self.store = store
        self.mainVC = mainVC
        self.pageVC = pageVC
        self.band = band
        super.init(style: .insetGrouped)
        if !self.songs.isEmpty { storedSelection = IndexPath(row: 0, section: 0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.backgroundColor = PaintCode.mediumDark
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.register(SongCell.self, forCellReuseIdentifier: "songCell")
        self.clearsSelectionOnViewWillAppear = false
        
        addButton.setBackgroundImage(PaintCode.imageOfPlusIcon, for: .normal)
        addButton.setBackgroundImage(PaintCode.imageOfPlusIconActive, for: .selected)
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        let addButtonItem = UIBarButtonItem(customView: addButton)
        
        editButton.setBackgroundImage(PaintCode.imageOfEditIcon, for: .normal)
        editButton.setBackgroundImage(PaintCode.imageOfEditIconActive, for: .selected)
        editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        let editButtonItem = UIBarButtonItem(customView: editButton)
        
        editSongButton.setBackgroundImage(PaintCode.imageOfEditSongIcon, for: .normal)
        editSongButton.addTarget(self, action: #selector(editSongButtonPressed), for: .touchUpInside)
        let editSongButtonItem = UIBarButtonItem(customView: editSongButton)

        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 20
        
        navigationItem.rightBarButtonItems = [editButtonItem, spacer, addButtonItem, spacer, editSongButtonItem]

        tableView.tableHeaderView = header  // Subclasses can set header.text to set the title
        
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore the selection (because editing mode removes the selection).
        guard let selection = storedSelection else { return }
        // guard songs.count > storedSelection.row else { return }
        tableView.selectRow(at: selection, animated: true, scrollPosition: .none)
        pageVC?.didSelectSongAtRow(selection.row)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func databaseDidChange(changedItems: [DatabaseStorable]) {
        print("databaseDidChange\n\n\n-------")
        
        // TODO: The dragging sometimes doesn't start. Also, the order often gets messed up, which only seems to happen when dragging the first or last item. I think I may have mixed UI related code and model/database related code, and this is what makes the behavior unstable. I should try to clean up my code structure.
        // DispatchQueue.main.async {
            self.tableView.reloadData()
        // }
        guard !songs.isEmpty else { storedSelection = nil; return }
        guard let storedSelection = storedSelection else { return }
        // DispatchQueue.main.async {
            self.tableView.selectRow(at: storedSelection, animated: false, scrollPosition: .none)

        // }
    }
    
    @objc func editSongButtonPressed() {
        guard let selection = selection else { return }
        
        // So the selection can be restored after the edit
        // storedSelection = tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
        guard let storedSelection = storedSelection else { return }
        storedSelectedSong = songs[storedSelection.row]
        
        let editVC = EditVC(store: store, song: songs[selection], band: band)
        editVC.modalPresentationStyle = .fullScreen
        self.present(editVC, animated: true)
    }
 
    
    @objc func addButtonPressed() {
        // Must be implemented by subclasses
    }
    
    @objc func editButtonPressed() {
        if !tableView.isEditing {
            tableView.setEditing(true, animated: true)
            editButton.isSelected = true
        } else {
            tableView.setEditing(false, animated: true)
            editButton.isSelected = false
        }
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
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.metadataDescription
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Store the selection in order to be able to restore it after editing, for example
        storedSelection = indexPath
        storedSelectedSong = songs[indexPath.row]
        
        pageVC?.didSelectSongAtRow(indexPath.row)
        editSongButton.isHidden = false
    }
    
//    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
//        // Store the current selection because editing cancels the selection
//        storedSelection = tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
//    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        // Restore the selection because editing cancels the selection
        guard let storedSelection = storedSelection else { return }
        tableView.selectRow(at: storedSelection, animated: true, scrollPosition: .none)
        self.pageVC?.didSelectSongAtRow(storedSelection.row)
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


extension SongtableVC: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = tableView
        return dragItems(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        let song = songs[indexPath.row]
        guard let textData = song.text.data(using: .utf8) else { return [] }
        let itemProvider = NSItemProvider(item: textData as NSData, typeIdentifier: kUTTypePlainText as String)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = song.id
        return [dragItem]
    }
}
