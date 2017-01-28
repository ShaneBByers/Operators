//
//  ChallengePuzzleCompletedViewController.swift
//  Operators
//
//  Created by Shane Byers on 1/28/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class ChallengePuzzleCompletedViewController: UIViewController {
    
    @IBOutlet weak var completedPuzzleLabel: UILabel!
    
    @IBOutlet weak var nextPuzzleButton: UIButton!
    
    var completedPuzzleText : String = ""
    
    var nextPuzzleText : String?
    
    
    func configureText(completedPuzzleDifficulty : Difficulty, completedPuzzleNumber : Int, nextPuzzleDifficulty : Difficulty?, nextPuzzleNumber : Int?) {
        completedPuzzleText = "\(completedPuzzleDifficulty.rawValue) Challenge Puzzle #\(completedPuzzleNumber + 1)"
        
        if let nextPuzzleDifficulty = nextPuzzleDifficulty,
            let nextPuzzleNumber = nextPuzzleNumber {
            nextPuzzleText = "\(nextPuzzleDifficulty.rawValue) Challenge Puzzle #\(nextPuzzleNumber + 1)"
        } else if let nextPuzzleDifficulty = nextPuzzleDifficulty {
            nextPuzzleText = "Continue to \(nextPuzzleDifficulty.rawValue) Puzzles"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        completedPuzzleLabel.text = completedPuzzleText
        
        if let nextPuzzleText = nextPuzzleText {
            nextPuzzleButton.setTitle(nextPuzzleText, for: .normal)
        } else {
            nextPuzzleButton.alpha = 0.0
            nextPuzzleButton.isEnabled = false
        }
    }
    
    @IBAction func nextPuzzleButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        
    }
}
