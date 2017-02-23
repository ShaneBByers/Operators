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
    
    var isInitial = true
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
        
        difficultyButtons[0].tintColor = .green
        difficultyButtons[1].tintColor = .yellow
        difficultyButtons[2].tintColor = .red
    }
    
    override func viewDidLayoutSubviews() {
        if isInitial {
            for difficultyButton in difficultyButtons {
                if difficultyButton.titleLabel!.text! == challengeModel.difficulty.rawValue {
                    difficultyButton.titleLabel!.font = UIFont(descriptor: difficultyButton.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: difficultyButton.titleLabel!.font.pointSize)
                    for (i,puzzleButton) in puzzleButtons.enumerated() {
                        puzzleButton.tintColor = difficultyButton.tintColor
                        puzzleButton.isEnabled = challengeModel.puzzleAvailableAt(index: i)
                    }
                }
            }
            isInitial = false
        }
    }
    
    @IBAction func difficultyButtonPressed(_ sender: UIButton) {
        
        let changed : Bool
        
        changed = challengeModel.setDifficulty(difficulty: Difficulty(rawValue: sender.titleLabel!.text!)!)
        
        if changed {
            
            for button in difficultyButtons {
                button.titleLabel!.font = UIFont(descriptor: button.titleLabel!.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits())!, size: button.titleLabel!.font.pointSize)
            }
            
            sender.titleLabel!.font = UIFont(descriptor: sender.titleLabel!.font.fontDescriptor.withSymbolicTraits(.traitBold)!, size: sender.titleLabel!.font.pointSize)
            
            for (i,button) in puzzleButtons.enumerated() {
                UIView.animate(withDuration: 0.2, animations: {
                    button.alpha = 0.0
                }) { (action) in
                    button.tintColor = sender.tintColor
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
    
    @IBAction func unwindToChallenge(segue: UIStoryboardSegue) {}
}
