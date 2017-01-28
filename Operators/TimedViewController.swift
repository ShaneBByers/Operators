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
    
    
    @IBOutlet var difficultyButtons: [UIButton]!
    
    @IBOutlet var timeButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func difficultyButtonPressed(_ sender: UIButton) {
        for button in difficultyButtons {
            button.titleLabel!.font = Fonts.smallRegular
        }
        
        sender.titleLabel!.font = Fonts.smallBold
        
        currentDifficulty = Difficulty(rawValue: sender.titleLabel!.text!)!
        
    }
    
    @IBAction func timeButtonPressed(_ sender: UIButton) {
        for button in timeButtons {
            button.titleLabel!.font = Fonts.smallRegular
        }
        
        sender.titleLabel!.font = Fonts.smallBold
        
        currentTime = sender.titleLabel!.text!
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "timedOptionsSelectedSegue":
            let destination = segue.destination as! PuzzleViewController
            
            let difficulty = currentDifficulty.rawValue
            
            let time = currentTime
            
            timedModel.initialize(withDifficulty: difficulty, withTime: time)
            
            destination.configureTimed(withDifficulty: difficulty, withTime: timedModel.totalTime!)
        case "unwindToGameType": break
        default: assert(false, "Unhandled Segue")
        }
    }
    
    @IBAction func unwindToTimed(segue: UIStoryboardSegue) {}
}
