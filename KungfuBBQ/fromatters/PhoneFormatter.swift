//
//  PhoneFormatter.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 18/08/21.
//

import Foundation

public class PhoneFormatter {
    
    // MARK: - Properties
    
    private var pattern: String
    
    private let digit: Character = "#"
    private let alphabetic: Character = "*"
    
    // MARK: - Lifecycle
    
    public init(pattern: String = "(###) ###-####") {
        self.pattern = pattern
    }
    
    public func formattedString(from plainString: String) -> String {
        guard !pattern.isEmpty else { return plainString }
        
        let pattern: [Character] = Array(self.pattern)
        let allowedCharachters = CharacterSet.alphanumerics
        let filteredInput = String(plainString.unicodeScalars.filter(allowedCharachters.contains))
        let input: [Character] = Array(filteredInput)
        var formatted: [Character] = []
        var patternIndex = 0
        var inputIndex = 0
        
        loop: while inputIndex < input.count {
            let inputCharacter = input[inputIndex]
            let allowed: CharacterSet
            
            guard patternIndex < pattern.count else { break loop }
            
            switch pattern[patternIndex] {
            case digit:
                allowed = .decimalDigits
            case alphabetic:
                allowed = .letters
            default:
                formatted.append(pattern[patternIndex])
                patternIndex += 1
                continue loop
            }
            
            guard inputCharacter.unicodeScalars.allSatisfy(allowed.contains) else {
                inputIndex += 1
                continue loop
            }
            formatted.append(inputCharacter)
            patternIndex += 1
            inputIndex += 1
        }
        return String(formatted)
    }
    public func returnPlainString(withPhoneFormatString phone:String)->String{
        return phone.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
    }
}
