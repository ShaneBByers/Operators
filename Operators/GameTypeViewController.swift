//
//  GameTypeViewController.swift
//  Operators
//
//  Created by Shane Byers on 1/27/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class GameTypeViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }

    @IBAction func unwindToGameType(segue: UIStoryboardSegue) {}
}
