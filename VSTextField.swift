//
//  VSTextField.swift
//
//  Created by Vojta Stavik on 09/03/15.
//  Copyright (c) 2015 www.STRV.com All rights reserved.
//

import UIKit

enum TextFieldFormatting {
    
    case SocialSecurityNumber
    case Default
}


class VSTextField: UITextField {

    /**
    Set a formatting pattern for a number and define a replacement string. For example: If formattingPattern would be "##-##-AB-##" and
    replacement string would be "#" and user input would be "123456", final string would look like "12-34-AB-56"
    */
    func setFormatting(formattingPattern: NSString, replacementString: NSString) {
        
        self.formattingPattern = formattingPattern
        self.replacementString = replacementString
    }
    
    
    /**
    String (usually a char) which will be replaced in formattingPattern by a number
    */
    var replacementString: NSString = "*"
    
    /**
    Max lenght of input string. You don't have to set this if you set formattingPattern.
    If 0 -> no limit.
    */
    var maxLenght = 0
    
    /**
    Type of predefined text formatting. You don't have to set this. (It's more a future feature)
    */
    var formatting : TextFieldFormatting = .Default {
        
        didSet {
            
            if formatting == .SocialSecurityNumber {
                
                self.formattingPattern = "***-**–****"
                self.maxLenght = self.formattingPattern.length
            }
            
            else {
                
                self.maxLenght = 9
            }
        }
    }
    
    
    /**
    String with formatting pattern for the text field.
    */
    var formattingPattern: NSString = "" {
        
        didSet {
            
            self.maxLenght = formattingPattern.length
        }
    }

    /**
    Text without formatting characters (read-only)
    */
    var textWithoutFormatting: String? {
        
        return pureString as? String
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        registerForNotifications()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        registerForNotifications()
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK - internal
    
    private func makeOnlyDigitsString(string: NSString) -> NSString {
    
        return (string.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) as! NSArray).componentsJoinedByString("")
    }

    
    private func numberOfDigitsInFormattingString(string: NSString) -> Int {

        var number: Int = 0
        
        for i in 0...max(0, string.length - 1) {
            
            if string.substringWithRange(NSMakeRange(i, 1)) == replacementString {
                
                number++
            }
        }
        
        return number
    }

    
    private var pureString: NSString = ""
    
    private func registerForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange", name: "UITextFieldTextDidChangeNotification", object: self)
    }
    
    
    func textDidChange() {
        
        if let textFieldString: NSString = self.text where formattingPattern != "" {
            
            pureString = makeOnlyDigitsString(textFieldString)
            
            var finalText = ""
            var stop = false
            
            var formatterIndex = 0
            var pureIndex = 0
            
            while !stop {
                
                if formattingPattern.substringWithRange(NSMakeRange(formatterIndex, 1)) != replacementString {
                    
                    finalText = finalText.stringByAppendingString(formattingPattern.substringWithRange(NSMakeRange(formatterIndex, 1)))
                }
                
                else if pureString.length > 0 {
                    
                    finalText = finalText.stringByAppendingString(pureString.substringWithRange(NSMakeRange(pureIndex, 1)))
                    pureIndex++
                }
                
                formatterIndex++
                
                if formatterIndex >= formattingPattern.length || pureIndex >= pureString.length {
                    
                    stop = true
                }
            }
            
            self.text = finalText
        }
        
        
        if maxLenght > 0 {
            
            if let text = self.text {
            
                if count(text) > maxLenght {
                    
                    self.text = self.text.substringToIndex(advance(self.text.startIndex, maxLenght))
                }
            }
        }
    }
}
