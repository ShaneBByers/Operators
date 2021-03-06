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
    
    var highScore : Int?
    
    var puzzleViewController : TimedPuzzleViewController?
    
    @IBOutlet weak var completedPuzzlesLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    
    func configureText(completedPuzzles: Int, score: Int, highScore: Int) {
        self.completedPuzzles = completedPuzzles
        self.score = score
        self.highScore = highScore
    }
    
    func configurePuzzleViewController(viewController : TimedPuzzleViewController) {
        puzzleViewController = viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completedPuzzlesLabel.text! = "Completed: " + String(self.completedPuzzles!) + " Puzzles"
        scoreLabel.text! = "Score: " + String(self.score!)
        highScoreLabel.text! = "High Score: " + String(self.highScore!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ColorScheme.updateScheme(forView: self.view)
    }
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        puzzleViewController!.restartTimedPuzzle()
        self.dismiss(animated: true)
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.puzzleViewController!.backButtonPressed(UIButton())
        }
    }
}
