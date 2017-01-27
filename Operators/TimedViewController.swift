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

    @IBOutlet weak var difficultySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var timeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "timedOptionsSelectedSegue":
            let destination = segue.destination as! PuzzleViewController
            
            let difficulty = difficultySegmentedControl.titleForSegment(at: difficultySegmentedControl.selectedSegmentIndex)!
            
            let time = timeSegmentedControl.titleForSegment(at: timeSegmentedControl.selectedSegmentIndex)!
            
            timedModel.initialize(withDifficulty: difficulty, withTime: time)
            
            destination.configureTimed(withDifficulty: difficulty, withTime: timedModel.totalTime!)
        case "unwindToGameType": break
        default: assert(false, "Unhandled Segue")
        }
    }
    
    @IBAction func unwindToTimed(segue: UIStoryboardSegue) {}
}
