//
//  MainVC.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 09.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

// TODO: When you delete a song from a setlist that is currently chosen, it is still shown in the SongVC. When you then swipe to the next song, and then back, the deleted song is shown again in the SongVC. I'm not sure where to fix this right now, because I haven't looked into the project for more than half a year. So I'm just noting this here to be looked after at some time.
// TODO: Similarly to the TODO above, when you drag a song into a set, the selection goes away. When you swipe, the old list of songs is used. You have to select a song in the list again to fix it.

import UIKit

class MainVC: UIViewController {    
    let store: DBStore
    let stackView = UIStackView()
    let pageVC = PageVC(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let listWidthMultiplier: CGFloat = 0.25  // This could be set in the user settings later
    var pickVC: PickVC!
    let navVC = UINavigationController()
    var currentBand: Band? {
        didSet {
            if let band = currentBand {
                self.pickVC.band = band
            }
        }
    }
    
    init(store: DBStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageVC.mainVC = self
        
        pickVC = PickVC(store: store)
        
        let overviewVC = OverviewVC(store: store)
        overviewVC.mainVC = self
        navVC.setViewControllers([overviewVC], animated: false)
        navVC.navigationBar.tintColor = .white
        navVC.navigationBar.barTintColor = PaintCode.mediumDark
        navVC.navigationBar.isTranslucent = false
        
        self.addChild(pageVC)
        self.addChild(pickVC)
        pickVC.view.isHidden = true
        self.addChild(navVC)
        pageVC.didMove(toParent: self)
        pickVC.didMove(toParent: self)
        navVC.didMove(toParent: self)
        
        stackView.addArrangedSubview(pageVC.view)
        stackView.addArrangedSubview(pickVC.view)
        stackView.addArrangedSubview(navVC.view)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        self.view.addSubview(stackView)
        
        navVC.view.translatesAutoresizingMaskIntoConstraints = false
        pickVC.view.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let listWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * self.listWidthMultiplier
        NSLayoutConstraint.activate([
            pickVC.view.widthAnchor.constraint(equalToConstant: listWidth),
            navVC.view.widthAnchor.constraint(equalToConstant: listWidth),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
    }
    
    func listButtonPressed() {
        if !pickVC.view.isHidden {
            hidePickVC()
            return
        }
        if !navVC.view.isHidden {
            hideList()
            pageVC.flipArrowToPointLeft()
            return
        }
        showList()
        pageVC.flipArrowToPointRight()
    }
    
    func showList() {
        UIView.animate(withDuration: 0.3) {
            self.navVC.view?.isHidden = false
            self.stackView.layoutIfNeeded()
        }
    }
    
    func hideList() {
        UIView.animate(withDuration: 0.3) {
            self.navVC.view?.isHidden = true
            self.stackView.layoutIfNeeded()
        }
    }
    
    func showPickVC(delegate: PickVCDelegate) {
        guard pickVC.view.isHidden else { return }
        self.pickVC.tableView.reloadData()
        self.pickVC.delegate = delegate
        UIView.animate(withDuration: 0.3) {
            self.pickVC.view.isHidden = false
            self.stackView.layoutIfNeeded()
        }
    }
    
    func hidePickVC() {
        guard !pickVC.view.isHidden else { return }
        // self.pickVC.stopListener()
        UIView.animate(withDuration: 0.3) {
            self.pickVC.view.isHidden = true
            self.stackView.layoutIfNeeded()
        }
        pickVC.delegate?.pickVCWasHidden()
    }
}


