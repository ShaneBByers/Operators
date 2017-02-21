//
//  DifficultyViewController.swift
//  Operators
//
//  Created by Shane Byers on 12/2/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

class DifficultyViewController: UIViewController {
    
    let bestScoreModel = BestScoreModel.sharedInstance

    @IBOutlet weak var easyHighScoreLabel: UILabel!
    
    @IBOutlet weak var mediumHighScoreLabel: UILabel!
    
    @IBOutlet weak var hardHighScoreLabel: UILabel!
    
    @IBOutlet weak var randomHighScoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        easyHighScoreLabel.text = String(bestScoreModel.highScore(forDifficulty: .easy))
        mediumHighScoreLabel.text = String(bestScoreModel.highScore(forDifficulty: .medium))
        hardHighScoreLabel.text = String(bestScoreModel.highScore(forDifficulty: .hard))
        randomHighScoreLabel.text = String(bestScoreModel.highScore(forDifficulty: .random))
        
        ColorScheme.updateScheme(forView: self.view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showPuzzleEasyDifficulty": showPuzzle(segue: segue, sender: sender)
        case "showPuzzleMediumDifficulty": showPuzzle(segue: segue, sender: sender)
        case "showPuzzleHardDifficulty": showPuzzle(segue: segue, sender: sender)
        case "showPuzzleRandomDifficulty": showPuzzle(segue: segue, sender: sender)
        case "unwindToGameType": break
        default: assert(false, "Unhandled Segue")
        }
    }
    
    func showPuzzle(segue: UIStoryboardSegue, sender: Any?) {
        let button = sender as! UIButton
        
        let difficulty = button.titleLabel!.text!
        
        let destinationViewController = segue.destination as! PuzzleViewController
        
        destinationViewController.configureBestScore(withDifficulty: difficulty)
    }
    
    @IBAction func unwindToOriginal(segue: UIStoryboardSegue) {}
    

}
