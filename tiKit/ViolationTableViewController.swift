//
//  ViolationTableViewController.swift
//  tiKit
//
//  Created by Thomas Hare on 8/8/15.
//  Copyright (c) 2015 raBit Software. All rights reserved.
//

//import Foundation
import UIKit

class ViolationTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var tableLayoutData :[Dictionary<String, AnyObject>]?
    var years = [String]()
    var models: [String] = []
    var dateFormatter = NSDateFormatter()
    var selectedIndexPath :NSIndexPath?
    let startYear = 1959
    
    enum FieldType: Int {
        case StandardPicker, DatePicker, ColorPicker, PhotoPicker, Normal
        var toString : String {
            switch self {
                // Use Internationalization, as appropriate.
            case .StandardPicker: return "Standard"
            case .DatePicker: return "Date"
            case .ColorPicker: return "Color"
            case .PhotoPicker: return "Photo"
            case .Normal: return "Normal"
            }
        }
    }
    
    // array which holds the data retrieved from the plist
    private var dataArray = [(String, ImplicitlyUnwrappedOptional<AnyObject>)]()
    private var keys = [String]()// keys are usually array of string types
    private var values = [AnyObject?]()// the values could be an array of any type
    private var keysArray: [String]?

    // plist filename (less the extension)
    var listName: String? = nil

    var tableViewBaseCellHeight: CGFloat = 0
    
    let colorPicker = ColorPicker(frame: CGRectZero)// init object with a zero frame size
    
    var colorPickerCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the array of years
        dateFormatter.dateFormat = "yyyy"
        let thisYear = Int(dateFormatter.stringFromDate(NSDate()))
        // create the years array
        for var year = startYear; year <= thisYear ; year++ { years.append(year.description) }

        // setup the tableview layout
        tableLayoutData = [
            ["title" : "Occurred On", "type" : FieldType.DatePicker.rawValue, "value" : NSDate(), "format" : "EEE, MMM d, yyyy H:mm a"],
            ["title" : "Manufacturer", "type" : FieldType.StandardPicker.rawValue, "source" : "Manufacturer", "value" : ""],
            ["title" : "Model", "type" : FieldType.StandardPicker.rawValue, "source" : models, "value" : "", "enabled" : false],
            ["title" : "Color", "type" : FieldType.ColorPicker.rawValue, "value" : "Gray"],
            ["title" : "Plate", "type" : FieldType.Normal.rawValue],
            ["title" : "Year", "type" : FieldType.StandardPicker.rawValue, "source" : years, "value" : dateFormatter.stringFromDate(NSDate())],
            ["title" : "State", "type" : FieldType.StandardPicker.rawValue, "source" : "State", "value" : ""],
            ["title" : "Location", "type" : FieldType.Normal.rawValue, "value" : "1 Infinite Loop Cupertino, CA 95014"],
            ["title" : "Evidence", "type" : FieldType.Normal.rawValue, "value" : "5 photos"],
            ["title" : "Notes", "type" : FieldType.Normal.rawValue, "value" : "Vehicle was observed parked facing the opposite direction and partially on the grass."]
        ]
        
        // set the default tableView cell height (44 usually)
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "NormalCell")
        tableViewBaseCellHeight = CGRectGetHeight(cell.frame)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var numberOfRows = tableLayoutData!.count
        
        if hasInlineTableViewCell() {
            numberOfRows += 1
        }
        return numberOfRows
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var dataRow = indexPath.row
        
        // the datarow is one less then the picker
        if selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row < indexPath.row {
            dataRow -= 1
        }
        
        // Configure the cell...
        var rowData = tableLayoutData![dataRow]
        let title = rowData["title"] as! String
//        let type = rowData["type"] as! PickerType
        let type = FieldType(rawValue: rowData["type"] as! Int)
        let enabled = rowData["enabled"] as? Bool
        
        // display the inline picker
        if selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row == indexPath.row - 1 {
            
            if type == FieldType.StandardPicker {
                
// MARK: Standard Picker
                
                // get a reusable cell that contains a pickerView
                let pickerViewCell = tableView.dequeueReusableCellWithIdentifier("PickerViewCell", forIndexPath: indexPath) as! PickerViewCell
                
                // TODO: load the data array
                if let source = rowData["source"] as? NSArray {
                    keys = source as NSArray as! [(String)]
//                    print(keys)// years
//                    dataArray = source as? [String]
                } else if let listName = rowData["source"] as? String {
                    // get data from a plist
                    dataArray = ListReader(listName).listData
                    // refresh the KV
                    keys = []
                    values = []
                    models = []
                    // parse the keys and values
                    for (k, v) in dataArray {
                        keys.append(k)
                        values.append(v)
                    }
                }
                
                // setup the datasource and delegate
                pickerViewCell.pickerView.delegate = self
                pickerViewCell.pickerView.dataSource = self;
                
                // set the default pickerView value
                if let value :AnyObject = rowData["value"] {
                    if let index = years.indexOf((value as! String)) {
                        // set the picker to the current item
                        pickerViewCell.pickerView.selectRow(index, inComponent: 0, animated: false)
                    }
                }
                return pickerViewCell
                
            } else if type == FieldType.DatePicker {
                
// MARK: Date Picker
                
                // get a reusable cell containing a datePicker
                let datePickerCell = tableView.dequeueReusableCellWithIdentifier("DatePickerCell", forIndexPath: indexPath) as! DatePickerCell
                
                // set the handler for the valueChanged event
                datePickerCell.datePicker.addTarget(self, action:"handleDatePickerValueChanged:", forControlEvents: .ValueChanged)

                // set the "date" datePicker to predetermined value
                if let date :AnyObject = rowData["value"] {
                    datePickerCell.datePicker.setDate(date as! NSDate, animated: true)
                }
                return datePickerCell
            } else if type == FieldType.ColorPicker {
                
// MARK: Color Picker
                
                // get a reusable cell containing a datePicker
                colorPickerCell = tableView.dequeueReusableCellWithIdentifier("ColorPickerCell", forIndexPath: indexPath)
                
                colorPicker.frame = CGRect(x: colorPickerCell!.frame.midX-113, y: 0, width: 216, height: 180)
                
                colorPickerCell!.addSubview(colorPicker)
                
                // set receiver function for spinner changed events
                colorPicker.addTarget(self, action: "spinnerColorChanged:", forControlEvents: .ValueChanged)

                colorPicker.blendBackGround(true)

                // load custom colors from the property list store
                loadCustomColors()// (optional)
                
                // sort the colors in the spinner (optional)
                colorPicker.sortColors(ascending: true)
                
                if let value: AnyObject = rowData["value"] {
                    // set the color to the current item
                    currentColor = (colorPicker.colors.filter {$0.name == value as! String}).first!.color
                }
                
                return colorPickerCell!
            } else if type == FieldType.PhotoPicker {
                
            }
        }
        
        // it's a "normal" cell so set that up instead
        let cell = tableView.dequeueReusableCellWithIdentifier("NormalCell", forIndexPath: indexPath) 
        
        // format the reusable cell
        
        // set the row title
        cell.textLabel?.text = title
        // if there's a value see if it needs formatting
        if let valueOfRow: AnyObject = rowData["value"] {
            if type == FieldType.DatePicker {
                if let type: AnyObject = rowData["format"] {
                    dateFormatter.dateFormat = type as! String
                    cell.detailTextLabel?.text = dateFormatter.stringFromDate(valueOfRow as! NSDate)
                } else {
                    dateFormatter.dateFormat = nil
                }
            } else {
                cell.detailTextLabel?.text = valueOfRow as? String
            }
        } else {
            // because there's no "value" defined for this cell
            cell.detailTextLabel?.text = ""
        }
        
        if enabled != nil { cell.userInteractionEnabled = enabled! }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // set the height for the current row
        var heightForRow :CGFloat = tableViewBaseCellHeight//44.0
        // if this is a picker cell adjust the height
        if selectedIndexPath != nil
            && selectedIndexPath!.section == indexPath.section
            && selectedIndexPath!.row == indexPath.row - 1 {
                heightForRow = 180//216.0
        }
        
        return heightForRow
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var dataRow = indexPath.row
        
        // data is on the previous row if an inline picker is visible
        if selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row < indexPath.row {
            dataRow -= 1
        }
        
        // get the data for the row that was selected
        var rowData = tableLayoutData![dataRow]
        let type = FieldType(rawValue: rowData["type"] as! Int)
        
        // display or hide the picker view
        if type != FieldType.Normal {
            displayOrHideInlinePickerViewForIndexPath(indexPath, (type?.toString)!);
        }
        
        // animated the cell selection animation
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // make sure the cell is visible
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        
    }
    
    // MARK: - picker utilities
    
    func displayOrHideInlinePickerViewForIndexPath(indexPath: NSIndexPath!, _ type: String) {
        tableView.beginUpdates()
        
        if selectedIndexPath == nil {
            // insert a new picker row
            selectedIndexPath = indexPath
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
            
        } else if selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row == indexPath.row {
            
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
            selectedIndexPath = nil
            
        } else if selectedIndexPath!.section != indexPath.section || selectedIndexPath!.row != indexPath.row {
            
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: selectedIndexPath!.row + 1, inSection: selectedIndexPath!.section)], withRowAnimation: .Fade)
            
            // After the deletion operation the then indexPath of original table view changed to the resulting table view
            if (selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row < indexPath.row) {
                
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)], withRowAnimation: .Fade)
                selectedIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
                
            } else {
                
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
                selectedIndexPath = indexPath
            }
        }
        
//                if selectedIndexPath == nil {
                    // reset the default value text color
//                    tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.textColor = nil
//                } else {
//                    tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.textColor = UIColor.redColor()
//                }
        
        tableView.endUpdates()
    }
    
    // returns boolean if a picker is currently displayed
    func hasInlineTableViewCell() -> Bool {
        return !(self.selectedIndexPath == nil)
    }
    
    // datePicker value changed target/action event handler
    func handleDatePickerValueChanged(datePicker: UIDatePicker!) {
        
        let index = selectedIndexPath!.row
        var rowData = tableLayoutData![index]
        
        // set the new value
        rowData["value"] = datePicker.date
        
        if var tmpArray = tableLayoutData {
            tmpArray[index] = rowData
            tableLayoutData = tmpArray
        }
        
        // updates the cell display for the changed value
        tableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: .Fade)
        
    }
    
    // MARK: - Picker view data source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    // MARK: - Picker view delegate

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return keys[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let index = selectedIndexPath!.row
        var rowData = tableLayoutData![index]
        
        rowData["value"] = keys[row]
        
        // puts the selected value into the field definition default
        if var tmpArray = tableLayoutData {
            tmpArray[index] = rowData
            tableLayoutData = tmpArray
        }
        
        // refresh the cell display
        tableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: .Fade)
    }
    
    // MARK: - Color picker properties
    
    var currentColor : UIColor = UIColor.grayColor()
        {
        didSet
        {
            colorPicker.removeTarget(self, action: "spinnerColorChanged:", forControlEvents: .ValueChanged)
            
            colorPicker.currentColor = currentColor
            
            // fill the background with color
            if colorPickerCell != nil {
                colorPickerCell!.backgroundColor = currentColor
            }
            
            let index = selectedIndexPath!.row
            var rowData = tableLayoutData![index]
            
            rowData["value"] = colorPicker.currentColorName
            
            // puts the selected value into the field definition default
            if var tmpArray = tableLayoutData {
                tmpArray[index] = rowData
                tableLayoutData = tmpArray
            }
            
            colorPicker.addTarget(self, action: "spinnerColorChanged:", forControlEvents: .ValueChanged)
            
            // updates the cell display for the changed value
            tableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func spinnerColorChanged(value : ColorPicker)
    {
        currentColor = value.currentColor
        
    }

    // loads the custom RGN colors from the property list and sorts them
    func loadCustomColors()
    {
        // load custom colors - get the property list data
        if let propertyListDict = getPropertyListData("CustomColors")
        {
            // create another array of color names
            keysArray = propertyListDict.allKeys as? [String]
            
            // add custom colors to default color list
            for key in keysArray!
            {
                // does it already exist by this name? (don't add duplicates)
                if colorPicker.colors.filter({$0.name == key}).isEmpty
                {
                    // collect the data from the dictionary
                    let colorItem: AnyObject = propertyListDict.objectForKey(key)!
                    let red = CGFloat((colorItem.objectForKey("R") as! NSString).floatValue)
                    let green = CGFloat((colorItem.objectForKey("G") as! NSString).floatValue)
                    let blue = CGFloat((colorItem.objectForKey("B") as! NSString).floatValue)
                    let customColor = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
                    
                    // create a NamedColor structure
                    let newColor = NamedColor(name: key, color: customColor)
                    // add it to the picker
                    colorPicker.addColor(newColor)
                }
            }
        }
    }
    
}