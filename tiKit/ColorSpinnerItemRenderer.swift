//
//  ColorSpinnerItemRenderer.swift
//
//  Created by Thomas Hare on 8/21/15.
//  Copyright (c) 2015 raBit Software. All rights reserved.
//
// based on Simon Gladman's "NumericDial" example of "ColorSpinner" https://github.com/FlexMonkey/NumericDialDemo.git
//
// renders the current line on the spinner. There is a label and a color swatch
import UIKit

class ColorSpinnerItemRenderer: UIControl
{
    let label = UILabel(frame: CGRectZero)
    let swatch = UIView(frame: CGRectZero)
    
    // initialize the control frame
    init(frame : CGRect, color : NamedColor)
    {
        // tell the controller the dimensions
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        
        // set the text and color swatch
        label.text = color.name
        
        swatch.backgroundColor = color.color
        swatch.layer.borderWidth = 1.5
        
        // add the items to the control view
        addSubview(label)
        addSubview(swatch)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    // whenever the window object changes notify so the objects can be sized within
    override func didMoveToWindow()
    {
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        swatch.frame = CGRect(x: 160, y: 80 / 2 - 7, width: 34, height: 14)
    }
    
}
