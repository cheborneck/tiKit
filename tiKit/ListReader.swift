//
//  ListReader.swift
//  Utility
//
//  Created by Thomas Hare on 8/3/15.
//  Copyright (c) 2015 raBit Software. All rights reserved.
//

import Foundation

/**
returns the sorted array of the selected plist

- parameter optional: name of plist file (do not include the extension name .plist)
*/
class ListReader {
    
    private var path:String?
    private var _listName:String?
    private var _listData = [(String, ImplicitlyUnwrappedOptional<AnyObject>)]()
    private var _sorted:Bool = true
    
    init(_ listName: String?){
        self._listName = listName
    }
    
    /// the name of the plist minus the extension
    var listName: String? {
        get {
            return _listName
        }
        set {
            _listName = newValue
        }
    }
    
    /**
    returns the list data
    
    - returns: optional array of data
    */
    var listData: [(String, ImplicitlyUnwrappedOptional<AnyObject>)] {
        get {
            if let path = NSBundle.mainBundle().pathForResource(_listName, ofType: "plist"), _ = NSDictionary(contentsOfFile: path)
            {
                if let loadedDictionary = readDictionaryFromFile(path) {
                    self._listData = loadedDictionary.sort { $0.0 < $1.0 }
                }
            }
            else {
                fatalError("Could not open \(_listName) plist")
            }
            return self._listData
        }
    }
    
    private func readDictionaryFromFile(filePath: String) -> Dictionary<String,AnyObject!>? {
        var anError : NSError?
        
        let data: NSData!
        do {
            data = try NSData(contentsOfFile: filePath, options: NSDataReadingOptions.DataReadingUncached)
        } catch let error as NSError {
            anError = error
            data = nil
        }
        if let _ = anError{
            return nil
        }
        
        let dict : AnyObject!
        do {
            dict = try NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions(rawValue: 0),format: nil)
        } catch let error as NSError {
            anError = error
            dict = nil
        }
        
        if (dict != nil) {
            if let ocDictionary = dict as? NSDictionary {
                var swiftDict : Dictionary<String,AnyObject!> = Dictionary<String,AnyObject!>()
                for key : AnyObject in ocDictionary.allKeys{
                    let stringKey : String = key as! String
                    
                    if let keyValue : AnyObject = ocDictionary.valueForKey(stringKey){
                        swiftDict[stringKey] = keyValue
                    }
                }
                return swiftDict
            } else {
                return nil
            }
        } else if let theError = anError {
            print("Sorry, couldn't read the file \(NSURL(string: filePath)!.lastPathComponent):\n\t" + theError.localizedDescription)
        }
        return nil
    }
    
}
