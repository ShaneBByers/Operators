//
//  TutorialViewController.swift
//  Operators
//
//  Created by Shane Byers on 4/12/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    let settingsModel = SettingsModel.sharedInstance

    override func viewDidLoad() {
        if settingsModel.tutorialShown {
//            performSegue(withIdentifier: "tutorialShownSegue", sender: self)
        }
        else
        {
            PuzzleModel.sharedInstance.gameType = .tutorial
        }
        
        PuzzleModel.sharedInstance.gameType = .tutorial
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        settingsModel.showTutorial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }
}
