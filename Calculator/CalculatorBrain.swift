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
    private var resultVal: Double? = 0
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
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "+": Operation.binaryOperation(+),
        "−": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.result
    ]
    
    
    // выполняем операцию
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                accumulatorString = symbol
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    accumulatorString = symbol + "(" + accumulatorString! + ")"
                } else {
                    resultVal = function(resultVal!)
                    resultString = symbol + "(" + resultString + ")"
                }
            case .binaryOperation(let function):
                if resultIsPending {
                    if accumulator != nil {
                        resultVal = pendingFunction(resultVal!, accumulator!)
                        resultString = resultString + pendingSymbol + accumulatorString!
                        accumulator = nil
                        accumulatorString = nil
                    }
                } else if resultString == ""{
                    resultVal = accumulator
                    
                    resultString = String(resultVal!)
                    accumulator = nil
                    accumulatorString = nil
                }
                pendingFunction = function
                pendingSymbol = symbol
                resultIsPending = true
            case .result:
                if resultIsPending {
                    if accumulator != nil {
                        
                        resultVal = pendingFunction(resultVal!, accumulator!)
                        resultString = resultString + pendingSymbol + accumulatorString!
                        accumulator = nil
                        accumulatorString = nil
                        
                    }
                }
                resultIsPending = false
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
            tmp += " " + pendingSymbol
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
