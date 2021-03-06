//
//  TimedViewController.swift
//  Operators
//
//  Created by Shane Byers on 12/10/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

class TimedViewController: UIViewController {
    
    let timedModel = TimedModel.sharedInstance

    var currentDifficulty : Difficulty = .easy
    
    var currentTime : String = "30 sec"
    
    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBOutlet var difficultyButtons: [UIButton]!
    
    @IBOutlet var timeButtons: [UIButton]!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "timedOptionsSelectedSegue":
            timedModel.initialize(withDifficulty: currentDifficulty, withTime: currentTime)
        case "unwindToGameType": break
        default: assert(false, "Unhandled Segue")
        }
    }
    
    override func viewDidLoad() {
        timedModel.initialize(withDifficulty: currentDifficulty, withTime: currentTime)
        PuzzleModel.sharedInstance.gameType = .timed
    }
    
    override func viewWillAppear(_ animated: Bool) {
        highScoreLabel.text = String(timedModel.highScore())
        ColorScheme.updateScheme(forView: self.view)
    }
    
    @IBAction func difficultyButtonPressed(_ sender: UIButton) {
        for button in difficultyButtons {
            button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits())!, size: button.titleLabel!.font.pointSize)
        }
        
        sender.titleLabel!.font = UIFont(descriptor: sender.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: sender.titleLabel!.font.pointSize)
        
        currentDifficulty = Difficulty(rawValue: sender.titleLabel!.text!)!
        
        timedModel.changeDifficulty(toDifficulty: currentDifficulty)
        
        highScoreLabel.text = String(timedModel.highScore())
        
    }
    
    @IBAction func timeButtonPressed(_ sender: UIButton) {
        for button in timeButtons {
            button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits())!, size: button.titleLabel!.font.pointSize)
        }
        
        sender.titleLabel!.font = UIFont(descriptor: sender.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: sender.titleLabel!.font.pointSize)
        
        currentTime = sender.titleLabel!.text!
        
        timedModel.changeTime(toTime: currentTime)
        
        highScoreLabel.text = String(timedModel.highScore())
        
    }
    
    @IBAction func unwindToTimed(segue: UIStoryboardSegue) {}
}
