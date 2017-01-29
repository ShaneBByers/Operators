//
//  ChallengeViewController.swift
//  Operators
//
//  Created by Shane Byers on 12/3/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

class ChallengeViewController: UIViewController {

    @IBOutlet var puzzleButtons: [UIButton]!
    
    @IBOutlet var difficultyButtons: [UIButton]!
    
    let challengeModel = ChallengeModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for (i,button) in puzzleButtons.enumerated() {
            button.isEnabled = challengeModel.puzzleAvailableAt(index: i)
        }
        
        for button in difficultyButtons {
            button.titleLabel!.font = Fonts.smallRegular
        }
        
        switch challengeModel.difficulty {
        case .easy: difficultyButtons[0].titleLabel!.font = Fonts.smallBold
        case .medium: difficultyButtons[1].titleLabel!.font = Fonts.smallBold
        case .hard: difficultyButtons[2].titleLabel!.font = Fonts.smallBold
        case .random: break
        }
    }
    
    
    @IBAction func difficultyButtonPressed(_ sender: UIButton) {
        
        let changed : Bool
        
        changed = challengeModel.setDifficulty(difficulty: Difficulty(rawValue: sender.titleLabel!.text!)!)
        
        if changed {
            
            for button in difficultyButtons {
                button.titleLabel!.font = Fonts.smallRegular
            }
            
            sender.titleLabel!.font = Fonts.smallBold
            
            for (i,button) in puzzleButtons.enumerated() {
                UIView.animate(withDuration: 0.2, animations: {
                    button.alpha = 0.0
                }) { (action) in
                    button.isEnabled = self.challengeModel.puzzleAvailableAt(index: i)
                    UIView.animate(withDuration: 0.2, animations: {
                        button.alpha = 1.0
                    })
                }
            }
        }
    }

    @IBAction func puzzleButtonPressed(_ sender: UIButton) {
        
        let title = Int(sender.titleLabel!.text!)!
        
        let index = title - 1
        
        self.performSegue(withIdentifier: "challengePuzzleSelectedSegue", sender: index)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        switch segue.identifier! {
        case "challengePuzzleSelectedSegue":
            let index = sender as! Int
            
            let equation = challengeModel.equationAtIndex(index: index)
            
            let destinationViewController = segue.destination as! PuzzleViewController
            
            destinationViewController.configureChallenge(withEquation: equation)
        case "unwindToGameType": break
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
    @IBAction func unwindToChallenge(segue: UIStoryboardSegue) {}
}
