//
//  GameModeViewController.swift
//  Operators
//
//  Created by Shane Byers on 1/27/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class GameModeViewController: UIViewController {
    
    let settingsModel = SettingsModel.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }

    @IBAction func unwindToGameMode(segue: UIStoryboardSegue) {}


}
