//
//  PuzzleModel.swift
//  Operators
//
//  Created by Shane Byers on 11/12/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

class PuzzleModel {
    static let sharedInstance = PuzzleModel()
    
    private let operators : [(Int,Int)->Int] = [OperatorFunctions.Add, OperatorFunctions.Subtract, OperatorFunctions.Multiply, OperatorFunctions.Divide]
    
    private let operatorStrings : [String] = [Symbols.Add, Symbols.Subtract, Symbols.Multiply, Symbols.Divide]
    
    var equation : Equation?
    
    func newEquation(operands: Int) -> Equation {
        
        var invalidSolution = true
        
        var _equation : [Element]?
        
        var solution : Int?
        
        while invalidSolution {
            
            _equation = []
            
            for i in 0..<operands {
                let _number = Element(String(Int(arc4random_uniform(10))))
                _equation!.append(_number)
                if i < operands - 1 {
                    let _operation = Element(operatorStrings[Int(arc4random_uniform(UInt32(operatorStrings.count)))])
                    _equation!.append(_operation)
                }
            }
            
            var _equationStrings : [String] = []
            
            for element in _equation! {
                _equationStrings.append(element.string)
            }
            
            var _expression : [String] = []
            
            var _doubleExpression : [String] = []
            
            for element in _equationStrings {
                switch element {
                case Symbols.Add:
                    _expression.append("+")
                    _doubleExpression.append("+")
                case Symbols.Subtract:
                    _expression.append("-")
                    _doubleExpression.append("-")
                case Symbols.Multiply:
                    _expression.append("*")
                    _doubleExpression.append("*")
                case Symbols.Divide:
                    _expression.append("/")
                    _doubleExpression.append("/")
                default:
                    _expression.append(element)
                    _doubleExpression.append(String(Double(element)!))
                }
            }
            
            let _expressionString = _expression.joined()
            let _doubleExpressionString = _doubleExpression.joined()
            
            let mathExpression = NSExpression(format: _expressionString, argumentArray: [])
            let doubleMathExpression = NSExpression(format: _doubleExpressionString, argumentArray: [])
            
            solution = mathExpression.expressionValue(with: nil, context: nil) as? Int
            let doubleSolution = doubleMathExpression.expressionValue(with: nil, context: nil) as? Double
            
            if Double(solution!) == doubleSolution {
                if let _ = solution {
                    invalidSolution = false
                }
            }
            
        }
        
        let _equals = Element(Symbols.Equals)
        _equation!.append(_equals)
        
        let _solutionString = String(solution!)
        
        let _solution = Element(_solutionString)
        
        equation = Equation(elements: _equation!, solution: _solution)
        
        return equation!
    }
    
    func solutionFor(expression : [String]) -> Int? {
        var _expression : [String] = []
        
        var operandCount = 0
        var operatorCount = 0
        
        for element in expression {
            switch element {
            case Symbols.Add:
                _expression.append("+")
                operatorCount += 1
            case Symbols.Subtract:
                _expression.append("-")
                operatorCount += 1
            case Symbols.Multiply:
                _expression.append("*")
                operatorCount += 1
            case Symbols.Divide:
                _expression.append("/")
                operatorCount += 1
            default:
                _expression.append(element)
                operandCount += 1
            }
        }
        
        if operandCount == operatorCount + 1 {
            let expressionString = _expression.joined()
            
            let mathExpression = NSExpression(format: expressionString, argumentArray: [])
            
            return mathExpression.expressionValue(with: nil, context: nil) as? Int
            
        } else {
            return nil
        }

    }
    
    func expressionWithSolutionFor(expression : [String]) -> String? {
        var _expression : [String] = []
        
        var operandCount = 0
        var operatorCount = 0
        
        for element in expression {
            switch element {
            case Symbols.Add:
                _expression.append("+")
                operatorCount += 1
            case Symbols.Subtract:
                _expression.append("-")
                operatorCount += 1
            case Symbols.Multiply:
                _expression.append("*")
                operatorCount += 1
            case Symbols.Divide:
                _expression.append("/")
                operatorCount += 1
            default:
                _expression.append(element)
                operandCount += 1
            }
        }
        
        if operandCount == operatorCount + 1 {
            let expressionString = _expression.joined()
            
            let mathExpression = NSExpression(format: expressionString, argumentArray: [])
            
            let solution = mathExpression.expressionValue(with: nil, context: nil) as? Int
            
            if let solution = solution {
                var _operatorExpression : [String] = []
                for element in _expression {
                    switch element {
                    case "+": _operatorExpression.append(Symbols.Add)
                    case "-": _operatorExpression.append(Symbols.Subtract)
                    case "*": _operatorExpression.append(Symbols.Multiply)
                    case "/": _operatorExpression.append(Symbols.Divide)
                    default:  _operatorExpression.append(element)
                    }
                }
                return _operatorExpression.joined(separator: " ") + " " + Symbols.Equals + " " + String(solution)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
