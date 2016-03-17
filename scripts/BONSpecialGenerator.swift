#!/usr/bin/env swift

//
//  BONSpecialGenerator.swift
//  BonMot
//
//  Created by Zev Eisenberg on 7/16/15.
//

import Foundation
import AppKit

// Please keep this array sorted
let specialCharacters: [unichar] = [
    0x0009,
    0x000A,
    0x0020,
    0x00A0,
    0x2002,
    0x2003,
    0x2007,
    0x2009,
    0x200A,
    0x200B,
    0x2011,
    0x2012,
    0x2013,
    0x2014,
    0x2026,
    0x2028,
    0x2029,
    0x202F,
    0x2060,
    0x2212,
    unichar(NSAttachmentCharacter), // 0xFFFC
]

// CFStringTransform doesn't do a good job of naming these characters, so override with custom names
let customMappings: [unichar: String] = [
    0x0009: "Tab",
    0x000A: "Line Feed",
    0x0020: "Space",
]

// These characters can't be represented with universal character syntax (@"\uXXXX"),
// so we use [NSString stringWithFormat:@"%C", BONCharacterFoo]. We don't do this with all
// characters, even though it would make the code look nicer, for performance reasons
let charactersRequiringFormatStrings: Set<unichar> = [
    0x0009,
    0x000A,
    0x0020,
]

// These special characters are to be excluded from the human readable string dictionary.
let charactersToExcludeFromHumanReadableStringDictionary: Set<unichar> = [
    0x0020,
]

extension unichar {
    var unicodeName: String {
        get {
            if let customName = customMappings[self] {
                return customName // bail early!
            }
            
            let swiftCharacter = Character(UnicodeScalar(self))
            
            let theCFMutableString = NSMutableString(string: String(swiftCharacter)) as CFMutableString
            CFStringTransform(theCFMutableString, UnsafeMutablePointer<CFRange>(nil), kCFStringTransformToUnicodeName, false)
            
            let characterName = theCFMutableString as String
            var trimmedName = characterName
            
            if characterName != String(swiftCharacter) {
                // characterName will look like "\N{NO-BREAK SPACE}", so trim "\N{" and "}"
                trimmedName = characterName[3..<characterName.utf8.count - 1]
            }
            
            return trimmedName
        }
    }
}

extension String {
    subscript(i: Int) -> Character {
        return self[startIndex.advancedBy(i)]
    }
    
    subscript(range: Range<Int>) -> String {
        return self[startIndex.advancedBy(range.startIndex)..<startIndex.advancedBy(range.endIndex)]
    }
    
    func camelCaseName(initialLetterCapitalized initialLetterCapitalized: Bool) -> String {
        let components: [String] = self.characters.split{$0 == " " || $0 == "-"}.map(String.init)
        var camelCaseComponents = components.map { $0.capitalizedString }
        if !initialLetterCapitalized && camelCaseComponents.count > 0 {
            camelCaseComponents[0] = camelCaseComponents[0].lowercaseString
        }
        return camelCaseComponents.joinWithSeparator("")
        
    }
    
    var methodName: String {
        return self.camelCaseName(initialLetterCapitalized: false)
    }
    
    var enumerationValueName: String {
        let camelCaseName = self.camelCaseName(initialLetterCapitalized: true)
        let fullName = "BONCharacter" + camelCaseName
        return fullName
    }
}

// from http://stackoverflow.com/a/31480534/255489
func pathToFolderContainingThisScript() -> String {
    let cwd = NSFileManager.defaultManager().currentDirectoryPath
    
    let script = Process.arguments[0];
    
    if script.hasPrefix("/") { // absolute
        let path = (script as NSString).stringByDeletingLastPathComponent
        return path
    }
    else { // relative
        let urlCwd = NSURL(fileURLWithPath: cwd)
        
        if let urlPath = NSURL(string: script, relativeToURL: urlCwd) {
            if let path = urlPath.path {
                let path = (path as NSString).stringByDeletingLastPathComponent
                return path
            }
        }
    }
    
    return ""
}

// ******************************
// *                            *
// *  Real program starts here  *
// *                            *
// ******************************

// Make sure specialCharacters is sorted
let sortedSpecialCharacters = specialCharacters.sort(<)
if sortedSpecialCharacters != specialCharacters {
    print("ERROR: The specialCharacters array is not sorted, and it must be.")
    exit(1)
}

// Populate strings with the declaration and implementation of the methods
var headerEnumString = "typedef NS_ENUM(unichar, BONCharacter) {\n"
var headerCodeString = ""
var implementationCodeString = ""
var humanReadableDictionaryContent = ""

for theUnichar in specialCharacters {
    let characterName = theUnichar.unicodeName
    let methodName = characterName.methodName
    let enumerationName = characterName.enumerationValueName
    
    let hexValueString = NSString(format:"%.4X", theUnichar)
    let enumerationStatement = "    \(enumerationName) = 0x\(hexValueString),\n"
    headerEnumString += enumerationStatement
    
    if !charactersToExcludeFromHumanReadableStringDictionary.contains(theUnichar) {
        let dictionaryStatement = "        @(\(enumerationName)) : @\"{\(methodName)}\", \n"
        humanReadableDictionaryContent += dictionaryStatement
    }
    
    let methodPrototype = "+ (NSString *)\(methodName)"
    let methodInterface = methodPrototype + ";"
    
    let returnExpression: String
    
    if charactersRequiringFormatStrings.contains(theUnichar) {
        returnExpression = NSString(format:"return [NSString stringWithFormat:@\"%%C\", %@];", enumerationName) as String
    }
    else {
        returnExpression = NSString(format:"return @\"\\u%.4X\";", theUnichar) as String
    }
    
    let methodImplementation = "\(methodPrototype) { \(returnExpression as String) }"
    
    headerCodeString += (methodInterface + "\n")
    implementationCodeString += (methodImplementation + "\n")
}

let humanReadableDictionaryHeaderDeclaration = "+ (BONGeneric(NSDictionary, NSNumber *, NSString *) *)humanReadableStringDictionary;"
let humanReadableDictionaryImplementation = "+ (BONGeneric(NSDictionary, NSNumber *, NSString *) *)humanReadableStringDictionary\n{\n    return @{\n" + humanReadableDictionaryContent + "    };\n}"

headerCodeString += ("\n" + humanReadableDictionaryHeaderDeclaration + "\n")
headerEnumString += "};"
implementationCodeString += ("\n" + humanReadableDictionaryImplementation + "\n")

// Get the contents of the template files

let currentDirectory = pathToFolderContainingThisScript()
let headerTemplatePath = (currentDirectory as NSString).stringByAppendingPathComponent("BONSpecial.h template.txt")
let implementationTemplatePath = (currentDirectory as NSString).stringByAppendingPathComponent("BONSpecial.m template.txt")

var headerTemplateString: String!
var implementationTemplateString: String!

do {
    headerTemplateString = try! NSString(contentsOfFile: headerTemplatePath, encoding: NSUTF8StringEncoding) as String
    implementationTemplateString = try! NSString(contentsOfFile: implementationTemplatePath, encoding: NSUTF8StringEncoding) as String
}

// Replace the template regions of the template files with the generated code
let replacementString = "{{ contents }}"

let fullHeaderString = headerEnumString + "\n\n" + headerCodeString

let headerOutputString = headerTemplateString.stringByReplacingOccurrencesOfString(replacementString, withString: fullHeaderString)
let implementationOutputString = implementationTemplateString.stringByReplacingOccurrencesOfString(replacementString, withString: implementationCodeString)

// Write the files out to the project directory

let projectDirectory = (currentDirectory as NSString).stringByDeletingLastPathComponent
let classesDirectory = (projectDirectory as NSString).stringByAppendingPathComponent("Pod/Classes")

let baseFileName = "BONSpecial"
let headerFileName = (baseFileName as NSString).stringByAppendingPathExtension("h")!
let implementationFileName = (baseFileName as NSString).stringByAppendingPathExtension("m")!
let headerFilePath = (classesDirectory as NSString).stringByAppendingPathComponent(headerFileName)
let implementationFilePath = (classesDirectory as NSString).stringByAppendingPathComponent(implementationFileName)

do {
    try! headerOutputString.writeToFile(headerFilePath, atomically: true, encoding: NSUTF8StringEncoding)
    try! implementationOutputString.writeToFile(implementationFilePath, atomically: true, encoding: NSUTF8StringEncoding)
    
    print("Updated \(headerFileName) and \(implementationFileName) in \(classesDirectory)")
    print("Please run `pod install` to update the headers in the example project.")
}
