//
//  MainVC.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 09.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    
    let stackView = UIStackView()
    let pageVC = PageVC(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let listWidthMultiplier: CGFloat = 0.25  // This could be set in the user settings later
    let pickVC = SongPickVC(style: .insetGrouped)
    let navVC = UINavigationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageVC.mainVC = self
        let overviewVC = OverviewVC(style: .insetGrouped)
        overviewVC.mainVC = self
        navVC.setViewControllers([overviewVC], animated: false)
        navVC.navigationBar.tintColor = .white
        navVC.navigationBar.barTintColor = PaintCode.mediumDark
        navVC.navigationBar.isTranslucent = false
        
        self.addChild(pageVC)
        // TODO: Add a pickVC, hidden at first, only showing when adding songs to a setlist
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
    
    func toggleList() -> Bool {
        guard let list = navVC.view else { fatalError("ListVC not found!") }
        UIView.animate(withDuration: 0.3) {
            list.isHidden = !list.isHidden
            self.stackView.layoutIfNeeded()
        }
        // Returns true if the list is visible after toggling
        return !list.isHidden
    }
    
    func showPickVC() {
        UIView.animate(withDuration: 0.3) {
            self.pickVC.view.isHidden = false
            self.stackView.layoutIfNeeded()
        }
    }
}


