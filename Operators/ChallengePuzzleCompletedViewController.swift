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
    
    var puzzleViewController : ChallengePuzzleViewController?
    
    func configureText(completedPuzzleDifficulty : Difficulty, completedPuzzleNumber : Int, nextPuzzleDifficulty : Difficulty?, nextPuzzleNumber : Int?) {
        completedPuzzleText = "\(completedPuzzleDifficulty.rawValue) Challenge Puzzle #\(completedPuzzleNumber + 1)"
        
        if let nextPuzzleDifficulty = nextPuzzleDifficulty,
            let nextPuzzleNumber = nextPuzzleNumber {
            nextPuzzleText = "\(nextPuzzleDifficulty.rawValue) Challenge Puzzle #\(nextPuzzleNumber + 1)"
        } else if let nextPuzzleDifficulty = nextPuzzleDifficulty {
            nextPuzzleText = "Continue to \(nextPuzzleDifficulty.rawValue) Puzzles"
        }
    }
    
    func configurePuzzleViewController(viewController : ChallengePuzzleViewController) {
        puzzleViewController = viewController
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
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }
    
    @IBAction func nextPuzzleButtonPressed(_ sender: UIButton) {
        puzzleViewController!.nextChallengePuzzle()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) { 
            self.puzzleViewController!.backButtonPressed(UIButton())
        }
    }
}
