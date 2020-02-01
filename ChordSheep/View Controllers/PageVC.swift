//
//  PageVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 02.04.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    weak var songtableVC: SongtableVC?
    weak var mainVC: MainVC?
    var listButton = UIButton.discreteButton(backgroundImage: PaintCode.imageOfHideListButton, target: self, action: #selector(listButtonPressed(_:)))
    // let editButton = DiscreteButton(title: "/", target: self, action: #selector(editButtonPressed(_:)))
    let pageControl = UIPageControl()  // TODO
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        setViewControllers([SongVC()], direction: .forward, animated: false)
        addButtons()
        
        self.view.backgroundColor = .black  // Without color, added gesture recognizers don't work
    }
    
    func addButtons() {
        view.addSubview(listButton)
        // view.addSubview(editButton)
        listButton.translatesAutoresizingMaskIntoConstraints = false
        // editButton.translatesAutoresizingMaskIntoConstraints = false
        
        var buttonConstraints = [
            listButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            listButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            listButton.heightAnchor.constraint(equalToConstant: 44),
            listButton.widthAnchor.constraint(equalToConstant: 44),
//            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
//            editButton.heightAnchor.constraint(equalToConstant: 44),
//            editButton.widthAnchor.constraint(equalToConstant: 44)
        ]
        // buttonConstraints.append(editButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0))

//        // Use Safe Area for top if available
//        if #available(iOS 11, *) {
//        } else {
//            buttonConstraints.append(editButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8))
//        }
        
        NSLayoutConstraint.activate(buttonConstraints)
    }
    
    @objc func listButtonPressed(_ sender: UIButton) {
        guard let mainVC = mainVC else { return }
        let isListVisible = mainVC.toggleList()

        // Flip button
        UIView.animate(withDuration: 1) {
            if isListVisible {
                UIView.transition(with: self.listButton, duration: 0.2, options: .transitionFlipFromRight, animations: {
                    self.listButton.setBackgroundImage(PaintCode.imageOfHideListButton, for: .normal)
                })

            } else {
                UIView.transition(with: self.listButton, duration: 0.2, options: .transitionFlipFromLeft, animations: {
                    self.listButton.setBackgroundImage(PaintCode.imageOfShowListButton, for: .normal)
                })
            }
        }
    }
    
    @objc func editButtonPressed(_ sender: UIButton) {
        let editVC = EditVC()
        guard let song = (viewControllers?.first as? SongVC)?.song else { return }
        editVC.songTextView.text = song.text
        editVC.delegate = songtableVC
        self.present(editVC, animated: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let songs = songtableVC?.songs,
            let currentVC = viewController as? SongVC
            else { return nil }
        
        let currentIndex = currentVC.index
        if currentIndex <= 0 { return nil }
        let newIndex = currentIndex - 1
        let newSong = songs[newIndex]

        return SongVC(with: newSong, index: newIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let songs = songtableVC?.songs,
            let currentVC = viewController as? SongVC
            else { return nil }
        
        let currentIndex = currentVC.index
        if currentIndex >= songs.count - 1 { return nil }
        let newIndex = currentIndex + 1
        let newSong = songs[newIndex]
        
        return SongVC(with: newSong, index: newIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        songtableVC?.tableView.isUserInteractionEnabled = false  // Otherwise tapping the list during the transition causes strange behavior
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        songtableVC?.tableView.isUserInteractionEnabled = true  // Has been disabled in func pageViewController(_:willTransitionTo:)

        guard let newVC = pageViewController.viewControllers?.first as? SongVC else { return }
        if completed {
            songtableVC?.swipedToPosition(newVC.index)
        }
    }
}

// MARK: Handle cell selection in ListVC
extension PageVC {
    func didSelectSongAtRow(_ index: Int) {
        guard let song = songtableVC?.songs[index] else { return }
        
        // If nothing is selected yet, the ListVC is just about to appear, so let the song slide in from the right
        guard let selection = songtableVC?.selection else {
            setViewControllers([SongVC(with: song, index: index)], direction: .forward, animated: true)
            return
        }

        if index > selection {
            setViewControllers([SongVC(with: song, index: index)], direction: .forward, animated: true)
        } else if index < selection {
            setViewControllers([SongVC(with: song, index: index)], direction: .reverse, animated: true)
        } else {
            setViewControllers([SongVC(with: song, index: index)], direction: .forward, animated: false)
        }
    }
}
