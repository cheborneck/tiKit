//
//  ColorSpinner.swift
//
//  Created by Thomas Hare on 8/21/15.
//  Copyright (c) 2015 raBit Software. All rights reserved.
//
// based on Simon Gladman's "NumericDial" example of "ColorSpinner" https://github.com/FlexMonkey/NumericDialDemo.git
//
// implemented new ability to add custom colors, sort color array, and put a transparent mask as background

import UIKit

class ColorPicker: UIControl, UIPickerViewDataSource, UIPickerViewDelegate
{
    // defines a default array of "NamedColor" structures (classes) from system colors
    var colors = [
        NamedColor(name: "Red", color: UIColor.redColor()),
        NamedColor(name: "White", color: UIColor.whiteColor()),
        NamedColor(name: "Green", color: UIColor.greenColor()),
        NamedColor(name: "Gray", color: UIColor.grayColor()),
        NamedColor(name: "Blue", color: UIColor.blueColor()),
        NamedColor(name: "Black", color: UIColor.blackColor()),
        NamedColor(name: "Cyan", color: UIColor.cyanColor()),
        NamedColor(name: "Yellow", color: UIColor.yellowColor()),
        NamedColor(name: "Magenta", color: UIColor.magentaColor()),
        NamedColor(name: "Brown", color: UIColor.brownColor())
    ]
    
    // create a spinner based on a blank picker view
    let spinner : UIPickerView = UIPickerView(frame: CGRectZero)
    
    // create a new view same size as picker for the cover view (if needed)
    var coverView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
//    var coverView = UIView()
    
    var currentColorName: String?
    
    /// add a custom named color to the current array
    func addColor(newColor: NamedColor)
    {
        colors.append(newColor)
        spinner.reloadAllComponents()
    }
    
    /// sort the colors array
    func sortColors( ascending ascending: Bool)
    {
        // which direction`
        if ( ascending )
        {
            colors.sortInPlace { $0.name < $1.name }
        } else {
            colors.sortInPlace { $0.name > $1.name }
        }
        spinner.reloadAllComponents()
    }
    
    /// displays the semi-transparent view (used for dark or colored backgrounds)
    func blendBackGround(blended: Bool)
    {
        // turn on the cover view for a better display effect
        if ( blended )
        {
            coverView.hidden = false
        } else {
            coverView.hidden = true
        }
    }
    
    override var frame: CGRect {
        didSet {
            // picker height is pinned at 180
            spinner.frame = CGRect(x: 0, y: 0, width: 216, height: 180)
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // create a semi-transparent layer so we can always read the text
//        coverView = UIView(frame: CGRect(x: 0, y: 0, width: 216, height: 180))
//        coverView.backgroundColor = UIColor.whiteColor()
//        coverView.alpha = 0.4
        coverView.frame = CGRectMake(0, 0, 216, 180)

        // usage optional, turned off by default
        coverView.hidden = true
        
        // add the cover view to the main view
        addSubview(coverView)
        
        backgroundColor = UIColor.clearColor()
        
        // all the contol and data feed is performed here
        spinner.delegate = self
        spinner.dataSource = self
        
        // add the spinner (pickerView)
        addSubview(spinner)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    var currentColor : UIColor = UIColor.blackColor()
        {
        didSet
        {
            // we'll notify the caller if the value changes
            sendActionsForControlEvents(.ValueChanged)
            
            var matchFound = false
            
            // get the index in the spinner for the selected color
            for (index, namedColor) in colors.enumerate()
            {
                if CGColorEqualToColor(namedColor.color.CGColor, currentColor.CGColor)
                {
                    spinner.selectRow(index, inComponent: 0, animated: false)
                    matchFound = true
                }
            }
            
            // set the default color to the first item in the array
            if !matchFound
            {
                spinner.selectRow(0, inComponent: 0, animated: false)
                spinner.reloadComponent(0)
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return colors[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        currentColorName = colors[row].name
        currentColor = colors[row].color
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        return CGFloat(frame.width)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return colors.count
    }
    
    // modifies the picker view to display the custom wheel
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        // get the custom color if on the first row or return the current color
        // let rendererColor = (row == 0) ? NamedColor(name: "Custom", color: currentColor) : colors[row]
        let rendererColor = colors[row]
        // render the picker view spinner
        return ColorSpinnerItemRenderer(frame: CGRectZero, color : rendererColor)
    }
    
}

struct NamedColor
{
    var name : String
    var color : UIColor
    
    init(name : String, color : UIColor)
    {
        self.name = name
        self.color = color
    }
}
