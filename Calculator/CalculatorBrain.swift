//
//  CalculatorBrain.swift
//  Calculator with history
//
//  Created by Виктор on 20.12.2017.
//  Copyright © 2017 Виктор. All rights reserved.
//

import Foundation

    struct CalculatorBrain {
    
    private var accumulator: (value: Double?, displayValue: String) = (nil, "")
    
    public var description: String?
        
    private var pendingBinaryOperation: PendingBinaryOperation?
        
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double, Int)
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
    "+": Operation.binaryOperation({$0 + $1}, 0),
    "-": Operation.binaryOperation({$0 - $1}, 0),
    "x": Operation.binaryOperation({$0 * $1}, 1),
    "/": Operation.binaryOperation({$0 / $1}, 1),
    //"log": Operation.binaryOperation({log($0) / log($1)}),
    "xʸ": Operation.binaryOperation({pow($0, $1)}, 2),
    "=": Operation.equals(),
    "C": Operation.clear()
    ]

    mutating func setAccumulator(value newValue: Double, displayValue: String?) {
        accumulator.value = newValue
        if(displayValue != nil){
                accumulator.displayValue = displayValue!
        }
        else {
        accumulator.displayValue = newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", newValue) : String(newValue)
        }
    }
        
    mutating func performOperation(_ symbol: String){
        
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                setAccumulator(value: value, displayValue: symbol)
                if resultIsPending == false {
                    description = accumulator.displayValue
                }
            case .unaryOperation(let function):
                if accumulator.value != nil {
                    setAccumulator(value: function(accumulator.value!), displayValue: symbol + addBrackets(to: accumulator.displayValue))

                    if resultIsPending == false {
                        description = accumulator.displayValue
                    }
 
                }
            case .binaryOperation(let function, let priority):
                if accumulator.value != nil {
        
                    if resultIsPending == false {
                        description = accumulator.displayValue
                    }
                    
                    if pendingBinaryOperation != nil {
                        performPendingBinaryOperation()
                        
                        if priority > pendingBinaryOperation!.priority {
                            description = addBrackets(to: description!)
                        }
                    }
                    
                    description! += symbol
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.value!, priority: priority, resultIsPending: true)
                    
                }
            case .equals:
                performPendingBinaryOperation()
                if pendingBinaryOperation != nil {
                    pendingBinaryOperation!.resultIsPending = false
                }
            case .clear:
                accumulator = (nil, "")
                description = nil
                pendingBinaryOperation = nil
            }
            
        }
        
        }
    
    private func addBrackets(to operand: String) -> String {
        return "(" + operand + ")"
    }
        
    private struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let firstOperand: Double
            let priority: Int
            var resultIsPending: Bool
        
            func perform(with secondOperand: Double) -> Double {
                return function(firstOperand, secondOperand)
            }
        }
    
    
    private mutating func performPendingBinaryOperation(){ // if press equals or binary operation (when pending)
        
     if(pendingBinaryOperation != nil && accumulator.value != nil ) {
        if pendingBinaryOperation!.resultIsPending == true {
            description! += accumulator.displayValue
            setAccumulator(value: pendingBinaryOperation!.perform(with: accumulator.value!), displayValue: description!)
            }
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        setAccumulator(value: operand, displayValue: nil)
    }
    
    var result: (Double?) {
        get {
            return accumulator.value
        }
    }
        
        var resultIsPending: Bool {
            get {
                if pendingBinaryOperation != nil {
                  return pendingBinaryOperation!.resultIsPending
                }
                else {
                    return false
                }
            }
        }

}
