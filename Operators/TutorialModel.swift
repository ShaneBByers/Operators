//
//  TutorialModel.swift
//  Operators
//
//  Created by Shane Byers on 4/26/17.
//  Copyright © 2017 Shane Byers. All rights reserved.
//

import Foundation

class TutorialModel {
    static let sharedInstance = TutorialModel()
    
    let equation : Equation
    
    init() {
        var elements : [Element] = []
        
        elements.append(Element("1"))
        elements.append(Element(Symbols.Add))
        elements.append(Element("2"))
        elements.append(Element(Symbols.Add))
        elements.append(Element("3"))
        elements.append(Element(Symbols.Equals))
        
        equation = Equation(elements: elements, solution: Element("6"))
    }
    
    func currentEquation() -> Equation {
        
        return equation
    }
}
