//
//  CalculatorBrain.swift
//  CalculatorHW
//
//  Created by Richard Poutier on 11/17/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    var accumulator: Double?
    
    var result: Double? {
        return accumulator
    }
    
    var description: String?
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    var pendingBinaryOperation: PendingBinaryOperation?
    
    enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
    }
    
    var Operations : Dictionary<String,Operation> = [
        "π" : .constant(Double.pi),
        "e" : .constant(M_E),
        "√" : .unary(sqrt),
        "^2": .unary({$0 * $0}),
        "÷" : .binary({$0 / $1}),
        "×" : .binary({$0 * $1}),
        "−" : .binary({$0 - $1}),
        "+" : .binary({$0 + $1}),
        "=" : .equals
    ]
    
    mutating func setOperand(_ value: Double) {
        if description != nil {
            description! += "\(value) "
        } else {
            description = "\(value) "
        }
        accumulator = value
    }
    
    
    mutating func performOperation(_ symbol: String) {
        
        if let op = Operations[symbol] {
            switch op {
            case .constant(let value):
                if description != nil {
                    description! += symbol + " "
                } else {
                    description = symbol + " "
                }
                
                accumulator = value
            case .unary(let function):
                
                if accumulator != nil {
                    if description != nil {
                        description!.insert("(", at: description!.startIndex)
                        description!.insert(")", at: description!.endIndex)
                        if symbol == "√" {
                            description!.insert("√", at: description!.startIndex)
                            description!.insert(" ", at: description!.endIndex)
                        } else {
                            //  symbol = ^2
                            description! += "^2 "
                        }
                    } else {
                        fatalError("This should never happen, description was nil even though accumulator exists")
                    }
                    
                    accumulator = function(accumulator!)
                }
            case .binary(let function):
                if accumulator != nil && pendingBinaryOperation != nil {
                    if description != nil {
                        if description!.count > 2 && symbol == "×" || symbol == "÷" {
                            description!.insert("(", at: description!.startIndex)
                            description!.insert(")", at: description!.endIndex)
                        }
                        description! += symbol + " "
                    }
                    
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(firstOperand: accumulator!, function: function)
                    accumulator = nil
                } else if accumulator != nil {
                    if description != nil {
                        if description!.count > 2 && symbol == "×" || symbol == "÷" {
                            description!.insert("(", at: description!.startIndex)
                            description!.insert(")", at: description!.endIndex)
                        }
                        description! += symbol + " "
                    } else {
                        description = symbol + " "
                    }
                    pendingBinaryOperation = PendingBinaryOperation(firstOperand: accumulator!, function: function)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    mutating func performPendingBinaryOperation() {
        if accumulator != nil && pendingBinaryOperation != nil  {
            accumulator = pendingBinaryOperation?.performOperation(accumulator!)
            pendingBinaryOperation = nil
        }
    }

    struct PendingBinaryOperation{
        var firstOperand: Double
        var function: (Double, Double) -> Double
        
        func performOperation(_ secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    enum ExpressionLiteral {
        case Operation(Operation)
        case Operand(Double)
    }
}
