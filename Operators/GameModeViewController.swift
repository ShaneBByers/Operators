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
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }

    @IBAction func singlePlayerButtonPressed(_ sender: UIButton) {
        //if settingsModel.tutorialShown {
        //    performSegue(withIdentifier: "showGameTypeSegue", sender: self)
        //} else {
            performSegue(withIdentifier: "showTutorialOptionsSegue", sender: self)
        //    settingsModel.showTutorial()
        //}
    }
    
    @IBAction func unwindToGameMode(segue: UIStoryboardSegue) {}
}
