//
//  ViewController.swift
//  Calculator
//
//  Created by Виктор on 17.12.2017.
//  Copyright © 2017 Виктор. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var desc: UILabel!
    
    var userIsInTheMiddleOfTyping = false

    
    var pointIsTouched = false
    
    private var brain = CalculatorBrain()
 
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", newValue) : String(newValue)
        }
    }

    
    var descValue: String {
        get {
            var result = ""
        
                if brain.description != nil {
                    result = brain.description!
                }
            
                if brain.resultIsPending == true {
                    return result  + "..."
                }
                else {
                    if brain.description != nil {
                        return result + "="
                    }
                    else {
                        return " "
                    }
                }
            
        
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }

    }
    
    @IBAction func touchPoint(_ sender: UIButton) {
        if pointIsTouched == false {
            if(userIsInTheMiddleOfTyping == true){
                display.text = display.text! + "."
            }
            else {
                display.text = "0."
                userIsInTheMiddleOfTyping = true
            }
            pointIsTouched = true
        }
    }

    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        userIsInTheMiddleOfTyping = false
        pointIsTouched = false // reset flags
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        else
        {
            displayValue = 0
        }
      
        desc.text = descValue
        
    }
    
}
