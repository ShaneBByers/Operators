//
//  TimedCompletedViewController.swift
//  Operators
//
//  Created by Shane Byers on 2/4/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import UIKit

class TimedCompletedViewController: UIViewController {
    
    var completedPuzzles : Int?
    
    var score : Int?
    
    var puzzleViewController : PuzzleViewController?
    
    @IBOutlet weak var completedPuzzlesLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        puzzleViewController!.restartTimedPuzzle()
        self.dismiss(animated: true)
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.puzzleViewController!.backButtonPressed(UIButton())
        }
    }
    
    func configureText(completedPuzzles: Int, score: Int) {
        self.completedPuzzles = completedPuzzles
        self.score = score
    }
    
    func configurePuzzleViewController(viewController : PuzzleViewController) {
        puzzleViewController = viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completedPuzzlesLabel.text! = "Completed: " + String(self.completedPuzzles!) + " Puzzles"
        scoreLabel.text! = "Score: " + String(self.score!)
    }
    

}
