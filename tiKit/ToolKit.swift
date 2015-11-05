//
//  ToolKit.swift
//  Color Picker
//
//  Created by Thomas Hare on 9/14/15.
//  Copyright (c) 2015 raBit Software. All rights reserved.
//

import Foundation

private let mainBundle = NSBundle.mainBundle()

func getPropertyListData(filename: String) -> NSDictionary?
{
    if let path = mainBundle.pathForResource(filename, ofType: "plist")
    {
        if let pListDict = NSDictionary(contentsOfFile: path)
        {
            return pListDict
        }
    }
    return nil
}
