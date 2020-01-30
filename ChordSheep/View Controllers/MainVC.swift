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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageVC.mainVC = self
        let overviewVC = OverviewVC(style: .insetGrouped)
        overviewVC.mainVC = self
        let navVC = UINavigationController(rootViewController: overviewVC)
        navVC.navigationBar.tintColor = .white
        
        self.addChild(pageVC)
        self.addChild(navVC)
        pageVC.didMove(toParent: self)
        navVC.didMove(toParent: self)
        
        stackView.addArrangedSubview(pageVC.view)
        stackView.addArrangedSubview(navVC.view)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        self.view.addSubview(stackView)
        
        navVC.view.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navVC.view.widthAnchor.constraint(equalTo: navVC.view.heightAnchor, multiplier: 2 / 10),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
    }
    
    func toggleList() {
        UIView.animate(withDuration: 0.3) {
            guard let list = self.stackView.arrangedSubviews.last else { return }
            list.isHidden = !list.isHidden
            self.stackView.layoutIfNeeded()
        }
    }
}


