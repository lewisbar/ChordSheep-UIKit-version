//
//  SongVC.swift
//  Choly
//
//  Created by Lennart Wisbar on 13.02.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

//protocol SongVCDelegate: AnyObject {
//    func receiveUpdate(for: Song)
//}

class SongVC: UIViewController {
        
    var songLabel = UILabel()
    var song: Song?
    var index = 0
    
    convenience init(with song: Song, index: Int) {
        self.init()
        self.song = song
        self.index = index
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PaintCode.dark
        let scrollView = UIScrollView()
        
        songLabel.lineBreakMode = .byWordWrapping
        songLabel.numberOfLines = 0
        songLabel.textColor = .white
        songLabel.attributedText = Style.styledText(for: song?.body ?? "")
        
        scrollView.addSubview(songLabel)
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        songLabel.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            songLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            songLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            songLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            songLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]
        
        let bottomConstraint = songLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        bottomConstraint.priority = .defaultLow
        constraints.append(bottomConstraint)
        
        // Use Safe Area for top if available
        if #available(iOS 11, *) {
            constraints.append(scrollView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0))
        } else {
            constraints.append(scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8))
        }
        
        NSLayoutConstraint.activate(constraints)
    }

    
    @IBAction func pinchedOnSongLabel(_ sender: UIPinchGestureRecognizer) {
        var pointSize = songLabel.font.pointSize * sender.scale
        
        // To prevent exponential scaling, reset the scale for each call, but only while the pinch lasts (state == .changed). For the states .began and .ended, don't reset the scale, so the last scale value will be saved for the next pinch, so the scale doesn't jump the next time the user pinches.
        if sender.state == .changed { sender.scale = 1.0 }
        
        let upperBound: CGFloat = 70
        let lowerBound: CGFloat = 10
        
        if pointSize < lowerBound {
            pointSize = lowerBound
        }
        else if pointSize > upperBound {
            pointSize = upperBound
        }
        
        songLabel.font = UIFont(name: songLabel.font.fontName, size: pointSize)
    }
}
