//
//  Equation.swift
//  Operators
//
//  Created by Shane Byers on 12/3/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

struct Equation {
    var elements : [Element]
    
    var solution : Element
    
    func toString() -> String {
        var returnString : String = ""
        for element in elements {
            returnString.append(element.string)
        }
        returnString.append(solution.string)
        
        return returnString
    }
}

struct Element {
    var operation : ((Int, Int) -> Int)?
    var number : Int?
    var equals : ((Int, Int) -> Bool)?
    var string : String
    
    init(_ aString: String) {
        string = aString
        switch string {
        case Symbols.Add:
            operation = OperatorFunctions.Add
        case Symbols.Subtract:
            operation = OperatorFunctions.Subtract
        case Symbols.Multiply:
            operation = OperatorFunctions.Multiply
        case Symbols.Divide:
            operation = OperatorFunctions.Divide
        case Symbols.Equals:
            equals = OperatorFunctions.Equals
        default:
            number = Int(string)!
        }
        
    }
}
