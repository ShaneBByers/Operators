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

    @IBOutlet var highScoreLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        highScoreLabels[0].text = String(bestScoreModel.highScore(forDifficulty: .easy))
        highScoreLabels[1].text = String(bestScoreModel.highScore(forDifficulty: .medium))
        highScoreLabels[2].text = String(bestScoreModel.highScore(forDifficulty: .hard))
        highScoreLabels[3].text = String(bestScoreModel.highScore(forDifficulty: .random))
        
        ColorScheme.updateScheme(forView: self.view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showPuzzleSegue": showPuzzle(segue: segue, sender: sender)
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
    
    @IBAction func difficultyButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showPuzzleSegue", sender: sender)
    }
    @IBAction func unwindToOriginal(segue: UIStoryboardSegue) {}
    

}
