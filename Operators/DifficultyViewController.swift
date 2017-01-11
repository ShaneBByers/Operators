//
//  DifficultyViewController.swift
//  Operators
//
//  Created by Shane Byers on 12/2/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

class DifficultyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let button = sender as! UIButton
        
        let difficulty = button.titleLabel!.text!
        
        let destinationViewController = segue.destination as! PuzzleViewController
        
        destinationViewController.configureBestScore(withDifficulty: difficulty)
    }
    

}
