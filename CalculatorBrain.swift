//
//  CalculatorBrain.swift
//  Calculator with history
//
//  Created by Виктор on 20.12.2017.
//  Copyright © 2017 Виктор. All rights reserved.
//

import Foundation

    struct CalculatorBrain {
    
    private var accumulator: Double?
        
    private var displayString: String? {
        get {
            if accumulator != nil {
                switch accumulator! {
                    case Double.pi:
                        return "π"
                    case M_E:
                        return "e"
                    default:
                        return accumulator!.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", accumulator!) : String(accumulator!)
                }
            }
            else {
                return nil
            }
        }
    }
    
    public var resultIsPending: Bool = false
    
    public var description: String?
        
    private var descPart2: String = ""
        
    public var comboOperation = false
        
    private var pendingBinaryOperation: PendingBinaryOperation?
        
    public var pendingComboOperation: PendingComboOperation?
        
    private var resultIsFixed = false
        
    public var lastOperation: String?
    
    private var lastOperationType: String?
        
    private var lastBinaryOperation: String?
        
    private let highPrioretyOperations = ["x", "/"]
        
    private let lowPrioretyOperations = ["+", "-"]
        
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals()
        case clear()
    }
    
    private var operations: Dictionary<String,Operation> = [
    "π": Operation.constant(Double.pi), //Double.pi,
    "e": Operation.constant(M_E), //M_E,
    "√": Operation.unaryOperation(sqrt), //sqrt,
    "cos": Operation.unaryOperation(cos), //cos
    "sin": Operation.unaryOperation(sin),
    "tan": Operation.unaryOperation(tan),
    "log₂": Operation.unaryOperation(log2),
    "log₃": Operation.unaryOperation({log($0) / log(3)}),
    "x²": Operation.unaryOperation({pow($0, 2)}),
    "x³": Operation.unaryOperation({pow($0, 3)}),
    "±": Operation.unaryOperation({-$0}),
    "+": Operation.binaryOperation({$0 + $1}),
    "-": Operation.binaryOperation({$0 - $1}),
    "x": Operation.binaryOperation({$0 * $1}),
    "/": Operation.binaryOperation({$0 / $1}),
    //"log": Operation.binaryOperation({log($0) / log($1)}),
    "xʸ": Operation.binaryOperation({pow($0, $1)}),
    "=": Operation.equals(),
    "C": Operation.clear()
    ]

    
    mutating func performOperation(_ symbol: String){
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                accumulator = value
                if resultIsPending {
                    if pendingComboOperation != nil {
                        pendingComboOperation!.descPart2 = symbol
                    }
                }
                else {
                    if description != nil {
                        description = symbol
                    }
                }
            case .unaryOperation(let function):
                
                if(resultIsPending) {
                    
                    comboOperation = true // binary + unary (unary operation under 2nd operand of binary operation)
                    
                    if pendingComboOperation == nil {
                        if(accumulator != nil){
                            descPart2 = symbol + addBrackets(to: displayString!)
                        }
                        else {
                            descPart2 = ""
                        }
                         print("{1}")
                    }
                    else {
                        if lastOperationType == "unary" {
                            descPart2 = symbol + addBrackets(to: pendingComboOperation!.descPart2)
                        }
                        else {
                             descPart2 = symbol + addBrackets(to: displayString!)
                        }
                        
                        print("{3}")
                    }
                    
                    print("\(description!), \(descPart2)")
                    
                   
                    pendingComboOperation = PendingComboOperation(descPart1: description!, descPart2: descPart2)
                    
                 
                    
                    print("\(pendingComboOperation!.descPart1), \(pendingComboOperation!.descPart2)")
                }
                
                else {
                   if accumulator != nil {
                        if description == nil {
                           description =  symbol + addBrackets(to: displayString!)
                        }
                        else {
                             description = symbol + addBrackets(to: (description!))
                        }
                    }
                }
                
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
              
                lastOperationType = "unary"
                
            case .binaryOperation(let function):
                
                if pendingBinaryOperation != nil && resultIsPending {
                    performPendingBinaryOperation() // 2 step of binary operation
                }
                
                /* 1 step of binary operation: save function and first operand: */

                if accumulator != nil {
                pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)                 }
                
                if  lastBinaryOperation != nil && description != nil {  // add brackets to description if last operation have low priority
                    if lowPrioretyOperations.contains(lastBinaryOperation!) && highPrioretyOperations.contains(symbol) {
                    description = addBrackets(to: description!)
                    }
                }
                
                if description == nil {
                    description = displayString! + symbol
                }
                else {
                    description = description! + symbol
                }
                
                comboOperation = false
                resultIsPending = true
                lastOperationType = "binary"
                lastBinaryOperation = symbol
           
            case .equals:
                if lastOperation == "=" {
                    break
                }
                if lastOperation == "unary" || resultIsPending == false {
                    break
                }
                performPendingBinaryOperation()
                resultIsPending = false
                comboOperation = false
                resultIsFixed = true
                pendingComboOperation = nil
                
            case .clear:
                accumulator = nil
                description = nil
                resultIsPending = false
                pendingBinaryOperation = nil
                comboOperation = false
                resultIsFixed = false
                lastOperation = nil
                lastOperationType = nil
                pendingComboOperation = nil
            }
            
            lastOperation = symbol
        }
        
        if description != nil {
            print("desc: \(description!)")
        }
    }
    
    private func addBrackets(to operand: String) -> String {
        return "(" + operand + ")"
    }
        
    private struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let firstOperand: Double
            
            func perform(with secondOperand: Double) -> Double {
                return function(firstOperand, secondOperand)
            }
        }
        
    public struct PendingComboOperation {
            var descPart1: String
            var descPart2: String
            mutating func performDescription() -> String {
                return descPart1 + descPart2
            }
        }
        
    
    private mutating func performPendingBinaryOperation(){ // if press equals or binary operation (when pending)
        
     if(pendingBinaryOperation != nil && accumulator != nil && description != nil ) {
        
            if comboOperation == false  {
                description = description! + displayString!
            }
            else {
                if pendingComboOperation != nil {
                    description = pendingComboOperation!.performDescription() // merge parts of description after combo operation is done
                }
            }
 
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
}
