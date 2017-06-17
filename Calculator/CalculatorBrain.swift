//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Zharaskhan Aman on 13.06.17.
//  Copyright © 2017 Zharaskhan. All rights reserved.
//
import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double? = 0
    private var accumulatorString: String? = ""
    private var resultVal: Double?
    private var resultString: String = ""
    
    private var resultIsPending = false
    private var pendingFunction: (Double, Double) -> Double = (+)
    private var pendingSymbol: String = ""
    
    // закачиваем операнд в модельку
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        accumulatorString = String(operand)
    
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double, String) -> (Double, String))
        case binaryOperation((Double, Double) -> Double)
        case result
        case clear
        case random
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation {(sqrt($0), "√(" + $1 + ")")},
        "±": Operation.unaryOperation {(-$0, "-(" + $1 + ")")},
        "cos": Operation.unaryOperation {(cos($0), "cos(" + $1 + ")")},
        "sin": Operation.unaryOperation {(sin($0), "cos(" + $1 + ")")},
        "x^2": Operation.unaryOperation {($0 * $0, "(" + $1 + ")^2")},
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.result,
        "Rand": Operation.random,
        "C": Operation.clear
    ]
    
    
    // performing operation
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
                case .constant(let value):
                    
                    accumulator = value
                    accumulatorString = symbol
                case .random:
                    //generating random number between 0 and 100 with 2 digits after floating point
                    accumulator = (Double(arc4random_uniform(101)) / 100.0)
                    accumulatorString = String(accumulator!)
                case .unaryOperation(let function):
                    if accumulator != nil {
                        //performing function on number in display
                        
                        let f = function(accumulator!, accumulatorString!)
                        accumulator = f.0
                        accumulatorString = f.1
                        
                    } else {
                        //performing function on result number
                        let f = function(resultVal!, resultString)
                        resultVal = f.0
                        resultString = f.1
                        
                        
                    }
                case .binaryOperation(let function):
                    if resultIsPending {
                        //performing delayed operation
                        if accumulator != nil {
                            resultVal = pendingFunction(resultVal!, accumulator!)
                            resultString = resultString + " " + pendingSymbol + " " + accumulatorString!
                        }
                    } else if resultString == ""{
                        resultVal = accumulator
                        resultString = accumulatorString!
                        
                    }
                    accumulator = nil
                    accumulatorString = nil
                    pendingFunction = function
                    pendingSymbol = symbol
                    resultIsPending = true
                case .result:
                    if resultIsPending {
                        //performing delayed operation
                        if accumulator != nil {
                            resultVal = pendingFunction(resultVal!, accumulator!)
                            resultString = resultString + " " + pendingSymbol + " " + accumulatorString!
                            accumulator = nil
                            accumulatorString = nil
                        }
                    }
                    resultIsPending = false
                case .clear:
                    
                    accumulator = 0
                    accumulatorString = ""
                    resultVal = nil
                    resultString = ""
                    
                    resultIsPending = false
                    pendingFunction = (+)
                    pendingSymbol = ""
            }
        }
    }
    
    var result: Double? {
        if accumulator != nil {
            return accumulator
        }
        return resultVal
    }
    
    var history: String? {
        var tmp = resultString
        if resultIsPending {
            tmp += " " + pendingSymbol + " "
            if (accumulator != nil) {
                tmp += accumulatorString!
            }
            tmp += " ... "
        } else {
            tmp += " = "
        }
        return tmp
    }
    
}
