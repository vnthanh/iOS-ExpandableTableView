//
//  ViewController.swift
//  Expandable
//
//  Created by Gabriel Theodoropoulos on 28/10/15.
//  Copyright © 2015 Appcoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate {

    // MARK: IBOutlet Properties
    @IBOutlet weak var tblExpandable: UITableView!
    
    // cell descriptions innitially loaded from plist file, contains: 1 array of (3 more array (of dictionaries))
    var cellDescriptors: NSMutableArray?
    // 2d array which stores the index of visible cells for each section
    var visibleRowsPerSection = [[Int]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        
        // load plist file
        self.loadCellDescriptors()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Custom Functions
    
    func configureTableView() {
        tblExpandable.delegate = self
        tblExpandable.dataSource = self
        tblExpandable.tableFooterView = UIView(frame: CGRect.zero)
        
        tblExpandable.register(UINib(nibName: "NormalCell", bundle: nil), forCellReuseIdentifier: "idCellNormal")
        tblExpandable.register(UINib(nibName: "TextfieldCell", bundle: nil), forCellReuseIdentifier: "idCellTextfield")
        tblExpandable.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
        tblExpandable.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "idCellSwitch")
        tblExpandable.register(UINib(nibName: "ValuePickerCell", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
        tblExpandable.register(UINib(nibName: "SliderCell", bundle: nil), forCellReuseIdentifier: "idCellSlider")
    }

    // Load plist file
    func loadCellDescriptors() {
        if let path = Bundle.main.path(forResource: "CellDescriptor", ofType: "plist") {
            cellDescriptors = NSMutableArray(contentsOfFile: path)
            
            // Innitial call of getIndicesOfVisibleRows()
            self.getIndicesOfVisibleRows()
            self.tblExpandable.reloadData()
        }
    }
    
    //
    func getIndicesOfVisibleRows() {
        self.visibleRowsPerSection.removeAll()
        
        for currentSectionCells in cellDescriptors! {
            var visibleRows = [Int]()
            
            let currentSection = currentSectionCells as! NSMutableArray
            
            for row in 0...(currentSection.count - 1) {
                let cell = currentSection[row] as! NSDictionary
                if cell["isVisible"] as! Bool == true {
                    visibleRows.append(row)
                }
            }
            
            self.visibleRowsPerSection.append(visibleRows)
        }
        //print(self.visibleRowsPerSection)
    }
    
    // 
    func getCellDescriptorForIndexPath(indexPath: NSIndexPath) -> [String: AnyObject] {
        let indexOfVisibleRow = self.visibleRowsPerSection[indexPath.section][indexPath.row]
        let item = self.cellDescriptors?[indexPath.section] as! NSMutableArray
        let cellDescriptor = item[indexOfVisibleRow] as! [String: Any]
        return cellDescriptor as [String : AnyObject]
    }
    
    // MARK: UITableView Delegate and Datasource Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.cellDescriptors != nil {
            return self.cellDescriptors!.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visibleRowsPerSection[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Personal"
        case 1:
            return "Preferences"
        default:
            return "Work Experience"
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath as NSIndexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCellDescriptor["cellIdentifier"] as! String, for: indexPath) as! CustomCell
        
        if currentCellDescriptor["cellIdentifier"] as! String == "idCellNormal" {
            if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                cell.textLabel?.text = primaryTitle as? String
            }
            
            if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                cell.detailTextLabel?.text = secondaryTitle as? String
            }
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellTextfield" {
            cell.textField.placeholder = currentCellDescriptor["primaryTitle"] as? String
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSwitch" {
            cell.lblSwitchLabel.text = currentCellDescriptor["primaryTitle"] as? String
            
            let value = currentCellDescriptor["value"] as? String
            cell.swMaritalStatus.isOn = (value == "true") ? true : false
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellValuePicker" {
            cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSlider" {
            let value = currentCellDescriptor["value"] as! String
            cell.slExperienceLevel.value = (value as NSString).floatValue
        }
        
        
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath as NSIndexPath)
        
        switch currentCellDescriptor["cellIdentifier"] as! String {
        case "idCellNormal":
            return 60.0
            
        case "idCellDatePicker":
            return 270.0
            
        default:
            return 44.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexOfTappedRow = self.visibleRowsPerSection[indexPath.section][indexPath.row]
        
        let section = cellDescriptors![indexPath.section] as! NSMutableArray
        let cell = section[indexOfTappedRow] as! NSDictionary
        
        if cell["isExpandable"] as! Bool == true {
            var shouldExpandAndShowSubRows = false
            if cell["isExpanded"] as! Bool == false {
                // In this case the cell should expand.
                shouldExpandAndShowSubRows = true
            }
            
            // Too long line of code to access a nested mutableArray
            let tappedRow = ((self.cellDescriptors![indexPath.section] as! NSMutableArray)[indexOfTappedRow] as! NSDictionary)
            tappedRow.setValue(shouldExpandAndShowSubRows, forKey: "isExpanded")
            
            
            //It contains the total number of additional rows that should be displayed when an expandable cell is expanded.
            let additionalRows = tappedRow["additionalRows"] as! Int
            
            for i in (indexOfTappedRow + 1)...(indexOfTappedRow + additionalRows) {
                // Too long line of code to access a nested mutableArray
                (section[i] as! NSDictionary).setValue(shouldExpandAndShowSubRows, forKey: "isVisible")
            }
        } else {
            //when such a cell is tapped, we want the respective top-level cell to collapse (and hide the options), and the value shown to the selected cell to be displayed to the top-level cell as well.
            if cell["cellIdentifier"] as! String == "idCellValuePicker" {
                var indexOfParentCell: Int!
                
                // Find parrent (expandable)
                for index in (0..<indexOfTappedRow).reversed() {
                    let cell = section[index] as! NSDictionary
                    if cell["isExpandable"] as! Bool == true {
                        indexOfParentCell = index
                        break
                    }
                }
                
                // Set parrent cell title after choosing
                let parentCell = (self.cellDescriptors![indexPath.section] as! NSMutableArray)[indexOfParentCell] as! NSDictionary
                parentCell.setValue((tblExpandable.cellForRow(at: indexPath) as! CustomCell).textLabel?.text, forKey: "primaryTitle")
                // Collapse parrent cell
                parentCell.setValue(false, forKey: "isExpanded")
                
                
                // Hide all child cells
                let additionalRows = parentCell["additionalRows"] as! Int
                for i in (indexOfParentCell + 1)...(indexOfParentCell + additionalRows) {
                    ((self.cellDescriptors![indexPath.section] as! NSMutableArray)[i] as! NSDictionary).setValue(false, forKey: "isVisible")
                }
            }
        }
        
        self.getIndicesOfVisibleRows()
        tblExpandable.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: UITableViewRowAnimation.fade)
    }
    
    // MARK: Custom cell delegate to display user input such as (date picker, switch)
    
    // Date time picker cell
    func dateWasSelected(_ selectedDateString: String) {
        let dateCellSection = 0
        let dateCellRow = 3
        
        ((self.cellDescriptors![dateCellSection] as! NSMutableArray)[dateCellRow] as! NSDictionary).setValue(selectedDateString, forKey: "primaryTitle")
        tblExpandable.reloadData()
    }
    
    // switch cell
    func maritalStatusSwitchChangedState(_ isOn: Bool) {
        let maritalSwitchCellSection = 0
        let maritalSwitchCellRow = 6
        
        let valueToStore = (isOn) ? "true" : "false"
        let valueToDisplay = (isOn) ? "Married" : "Single"
        
        
        ((self.cellDescriptors![maritalSwitchCellSection] as! NSMutableArray)[maritalSwitchCellRow] as! NSDictionary).setValue(valueToStore, forKey: "value")
        ((self.cellDescriptors![maritalSwitchCellSection] as! NSMutableArray)[maritalSwitchCellRow] as! NSDictionary).setValue(valueToDisplay, forKey: "primaryTitle")
        tblExpandable.reloadData()
    }
    
    // text field cell
    func textfieldTextWasChanged(_ newText: String, parentCell: CustomCell) {
        let parentCellIndexPath = tblExpandable.indexPath(for: parentCell)
        
        let currentFullname = ((self.cellDescriptors![0] as! NSMutableArray)[0] as! NSDictionary)["primaryTitle"] as! String
        let fullnameParts = currentFullname.components(separatedBy: " ")
        
        var newFullname = ""
        
        if parentCellIndexPath?.row == 1 {
            if fullnameParts.count == 2 {
                newFullname = "\(newText) \(fullnameParts[1])"
            }
            else {
                newFullname = newText
            }
        }
        else {
            newFullname = "\(fullnameParts[0]) \(newText)"
        }
        
        
        ((self.cellDescriptors![0] as! NSMutableArray)[0] as! NSDictionary).setValue(newFullname, forKey: "primaryTitle")
        tblExpandable.reloadData()
    }
    
    // Slider cell
    func sliderDidChangeValue(_ newSliderValue: String) {
        ((self.cellDescriptors![2] as! NSMutableArray)[0] as! NSDictionary).setValue(newSliderValue, forKey: "primaryTitle")
        ((self.cellDescriptors![2] as! NSMutableArray)[1] as! NSDictionary).setValue(newSliderValue, forKey: "value")
        
        tblExpandable.reloadSections(NSIndexSet(index: 2) as IndexSet, with: UITableViewRowAnimation.none)
    }
}

