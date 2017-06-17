//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Zharaskhan Aman on 13.06.17.
//  Copyright © 2017 Zharaskhan. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    
    
    var displayNumber: Double? = 0
    var historyString: String?
    
    
    
    
  
    
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
        case clear()
    }
    enum expressionType {
        case number
        case sign
        
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "%": Operation.unaryOperation({$0 / 100}),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.result,
        "C": Operation.clear()
    ]
    
    
    struct historyStruct {
        var array: [(String, Any, expressionType)] = []
        
        func lastElementExpressionType() -> expressionType? {
            return self.array.last?.2
        }
        mutating func removeLast() {
            self.array.popLast()
        }
        mutating func clear() {
            self.array.removeAll()
        }
        mutating func append(_ viewString: String, _ value: Any, _ type: expressionType) {
            self.array.append((viewString, value, type))
        }
        func getSum() -> (String, Any, expressionType)? {
            if array.isEmpty == false {
                var viewString = self.array[0].0
                var result = self.array[0].1 as! Double
                
                
                for i in stride(from: 2, to: array.count, by: 2) {
                    viewString += " " + self.array[i - 1].0 + " " + self.array[i].0
                    let f: ((Double, Double) -> (Double))  = self.array[i - 1].1 as! (Double, Double) -> (Double)
                    result = f(result, self.array[i].1 as! Double)
                }
                
            
                return (viewString, result, expressionType.number)
            }
            
            return nil
        }
    }
    var history: historyStruct? = historyStruct()
    
    
    // закачиваем операнд в модельку
    mutating func setOperand(_ operandd: Double) {
        if history?.lastElementExpressionType() == expressionType.number {
            history?.clear()
        }
        
        history?.append(String(operandd), operandd, expressionType.number)
        
        displayNumber = history?.getSum()?.1 as! Double
        historyString = history?.getSum()?.0
        
    }
    
    // выполняем операцию
    mutating func performOperation(_ symbol: String) {
      
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                if history?.lastElementExpressionType() == expressionType.number {
                    history?.clear()
                }
                history?.append(symbol, value, expressionType.number)
            case .unaryOperation(let function):
                if history?.lastElementExpressionType() == expressionType.number {
                    var tmp = history!.array.popLast()!
                    tmp.1 = function(tmp.1 as! Double)
                    tmp.0 = symbol + "(" + tmp.0 + ")"
                    history!.array.append(tmp)
                }
                
                break
                
            case .clear():
                
                break
            case .binaryOperation(let function):
                if history?.lastElementExpressionType() == expressionType.sign {
                    history?.removeLast()
                }
                history?.append(symbol, function, expressionType.sign)
               break
            case .result:
                
                break
            }
            
        }
        print (history?.getSum()?.0)
        displayNumber = history?.getSum()?.1 as! Double
        historyString = history?.getSum()?.0
        
        if history?.lastElementExpressionType() == expressionType.sign {
            historyString? += history!.array.last!.0 + " ..."
        } else {
            historyString? += " = "
        }
    }
    
    
        
}
