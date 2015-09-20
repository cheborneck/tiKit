//
//  PickerController.swift
//  tiKit
//
//  Created by Thomas Hare on 8/3/15.
//  Copyright (c) 2015 raBit Software. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBookUI

class PickerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    // MARK: - properties
    
    var mfgKeys = [String]()
    var mfgValues = [AnyObject?]()
    var modelKeys = [String]()
    var modelValues = [AnyObject?]()
    var stateKeys = [String]()
    var stateValues = [AnyObject?]()
    
    let locationManager = CLLocationManager()
    var addressInfo = String()
    
    private var pList = [(String, ImplicitlyUnwrappedOptional<AnyObject>)]()
    private var myPicker = UIPickerView()
    
    private var editMode:Bool = false
    
    var textFields:[UITextField]? = nil
    var activeTextField:UITextField? = nil
    
    enum propertyListName: Int {
        case Manufacturer
        case Model
        case State
        
        var text: String {
            get {
                switch self {
                case .Manufacturer:
                    return "Manufacturer"
                case .Model:
                    return "Model"
                case .State:
                    return "State"
                }
            }
        }
    }
    
    // MARK: - outlets
    
    @IBOutlet weak var mfgTextField: UITextField!
    
    @IBOutlet weak var modelTextField: UITextField!
    
    @IBOutlet weak var stateTextField: UITextField!
    
    @IBOutlet weak var currentLocation: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // receive messages for the picker
        myPicker.delegate = self
        
        // start out not being able to select this field
        modelTextField.enabled = false
        
        // set up textfields
        textFields = [UITextField]()
        searchTextFields(self.view)
        
        // setup to get the user location
        activityIndicator.startAnimating()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // just need to make sure we can't select a specific model if no mfg is selected.
    @IBAction func textField_EditingDidEnd(sender: UITextField) {
        modelTextField.enabled = mfgTextField.text != ""
    }
    
    @IBAction func textField_EditingDidBegin(sender: UITextField) {
        if (editMode) { return }
        activeTextField = sender
        
        // prepare the datasource when a new field is selected
        if let propertyListItem = propertyListName(rawValue: activeTextField!.tag) {
            switch (propertyListItem) {
            case .Manufacturer:
                setPickerField(propertyListName.Manufacturer, textField: activeTextField!, keys: &mfgKeys, values: &mfgValues)
            case .Model:
                // get the key into the array
                if let index = mfgKeys.indexOf(mfgTextField.text!) {
                    // pull out the keys
                    modelKeys = (mfgValues[index] as? [String])!
                    setPickerField(propertyListName.Model, textField: activeTextField!, keys: &modelKeys, values: &modelValues)
                }
            case .State:
                setPickerField(propertyListName.State, textField: activeTextField!, keys: &stateKeys, values: &stateValues)
                //            default: break
            }
        }
        
        // set the state of the navigational buttons
        let toolbar = activeTextField!.inputAccessoryView as! UIToolbar
        if activeTextField!.tag == textFields?.first?.tag {
            toolbar.items?[0].enabled = false
            toolbar.items?[1].enabled = true
        } else if activeTextField!.tag == textFields?.last?.tag {
            toolbar.items?[0].enabled = true
            toolbar.items?[1].enabled = false
        } else {
            toolbar.items?[0].enabled = true
            toolbar.items?[1].enabled = true
        }
        
    }
    
    @IBAction func UIButton_TouchUpInside(sender: UIButton) {
        let thisButon = sender
        
        if let propertyListItem = propertyListName(rawValue: thisButon.tag) {
            switch (propertyListItem) {
            case .Manufacturer:
                editMode = true
                mfgTextField!.inputView = nil
                mfgTextField!.inputAccessoryView = nil
                mfgTextField!.resignFirstResponder()
                mfgTextField!.keyboardType = UIKeyboardType.Default
                mfgTextField!.becomeFirstResponder()
            default: break
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let propertyListItem = propertyListName(rawValue: textField.tag) {
            switch (propertyListItem) {
            case .Manufacturer:
                setPickerField(propertyListName.Manufacturer, textField: activeTextField!, keys: &mfgKeys, values: &mfgValues)
            default: break
            }
        }
        return true
    }
    
    @IBAction func geoUpdate_TouchUpInside(sender: UIButton) {
        currentLocation.text = ""
        activityIndicator.startAnimating()
        locationManager.startUpdatingLocation()
    }
    
    func textFieldValueChanged(sender: UITextField) {
        // decide whether to enable the model selector
        modelTextField.enabled = (mfgTextField.text != "")
    }
    
    // MARK: - location management
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                self.currentLocation.text = "Reverse geocoder failed with error. \n" + error!.localizedDescription
            } else {
                if placemarks!.count > 0 {
                    //                    let pm = placemarks[0] as! CLPlacemark
                    self.displayLocationInfo(placemarks?.first)
                } else {
                    print("Problem with the data received from geocoder")
                }
            }
            //stop updating location to save battery life
            self.locationManager.stopUpdatingLocation()
            self.activityIndicator.stopAnimating()
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if placemark != nil {
            // update the location display
            addressInfo = ABCreateStringWithAddressDictionary(placemark!.addressDictionary!, false)
            currentLocation.text = addressInfo
        }
    }
    
    // MARK: - pickerView management
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // failable initializer - could return a number that doesn't exist
        if let propertyListItem = propertyListName(rawValue: pickerView.tag) {
            switch (propertyListItem) {
            case .Manufacturer:
                return mfgKeys.count
            case .Model:
                return modelKeys.count
            case .State:
                return stateKeys.count
            }
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let propertyListItem = propertyListName(rawValue: pickerView.tag) {
            switch (propertyListItem) {
            case .Manufacturer:
                return mfgKeys[row]
            case .Model:
                return modelKeys[row]
            case .State:
                return stateKeys[row]
            }
        }
        return nil
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let propertyListItem = propertyListName(rawValue: pickerView.tag) {
            switch (propertyListItem) {
            case .Manufacturer:
                mfgTextField.text = mfgKeys[row]
                modelTextField.text = ""
            case .Model:
                modelTextField.text = modelKeys[row]
            case .State:
                stateTextField.text = "\(stateKeys[row]) - (\(stateValues[row]!))"
                //            default: break
            }
        }
    }
    
    // MARK: - Helper functions
    
    // Search for all textFields in your view (and subviews), if tag is greater than 0, connect delegate and append to ‘textFields’ array.
    func searchTextFields(_view: UIView) {
        for subView in _view.subviews {
            if subView.isKindOfClass(UITextField) {
                let textField = subView as! UITextField
                //                if textField.tag > 0 {
                textField.delegate = self
                textFields?.append(subView as! UITextField)
                //                }
            } else if subView.isKindOfClass(UIView) {
                searchTextFields(subView )
            }
        }
    }
    
    /// setup the picker with data for the appropriate field
    func setPickerField(listName: propertyListName, textField: UITextField, inout keys: [String], inout values: [AnyObject?]) {
        // load in the list for the selected field. models are special case as they are an array of values from the mfg list
        if (listName != .Model) {
            pList = ListReader(listName.text).listData
            for (k, v) in pList {
                keys.append(k)
                values.append(v)
            }
        }
        
        // sreload picker data
        myPicker.dataSource = self
        myPicker.reloadAllComponents()
        
        // setup other pickerView features
        myPicker.tag = listName.rawValue
        textField.inputView = myPicker
        
        // see if there's a previous value and set the wheel index
        if (textField.text != "") {
            if let index = keys.indexOf(textField.text!) {
                // set the picker to the current item
                myPicker.selectRow(index, inComponent: 0, animated: false)
            }
        } else {
            // set the text field to the first item displayed when the picker is displayed
            textField.text = keys[myPicker.selectedRowInComponent(0)]
            switch (listName) {
            case .Manufacturer:
                modelTextField.enabled = true
            case .State:
                textField.text = "\(keys[myPicker.selectedRowInComponent(0)]) - (\(values[myPicker.selectedRowInComponent(0)]!))"
            default: break
            }
            if listName == .Manufacturer {
                modelTextField.enabled = true
            }
        }
        
        // layout the button for the toolbar
        let nextButton = UIBarButtonItem(image: UIImage(named: "right"), style: UIBarButtonItemStyle.Plain, target: self, action: "nextButton")
        let previousButton = UIBarButtonItem(image: UIImage(named: "left"), style: UIBarButtonItemStyle.Plain, target: self, action: "previousButton")
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: textField, action: "resignFirstResponder")
        _ = [AnyObject]()
        
        // create the picker toolbar
        let pickerToolbar = UIToolbar()
        pickerToolbar.barStyle = UIBarStyle.Default
        pickerToolbar.translucent = true
        pickerToolbar.tintColor = nil
        pickerToolbar.sizeToFit()
        
        //Order buttons
        let buttonsArray = [previousButton, nextButton, flexSpace, doneButton]
        //        let buttonsArray = [flexSpace, doneButton]
        pickerToolbar.items = buttonsArray
        
        // plug the toolbar into the textfield
        for textField in textFields! {
            textField.inputAccessoryView = pickerToolbar
        }
        
    }
    
    func nextButton() {
        if activeTextField?.tag != textFields?.last?.tag {
            textFields?[activeTextField!.tag + 1].becomeFirstResponder()
        }
    }
    
    func previousButton() {
        if activeTextField?.tag != textFields?.first?.tag {
            textFields?[activeTextField!.tag - 1].becomeFirstResponder()
        }
    }
    
}
