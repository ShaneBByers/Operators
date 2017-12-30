//
//  TutorialViewController.swift
//  Operators
//
//  Created by Shane Byers on 4/12/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        PuzzleModel.sharedInstance.gameType = .tutorial
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }
}
