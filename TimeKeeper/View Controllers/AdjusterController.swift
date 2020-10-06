//
//  AdjusterController.swift
//  TimeKeeper
//
//  Created by John Postlewaite on 7/29/20.
//  Copyright © 2020 John Postlewaite. All rights reserved.
//

import UIKit
import CoreData

class AdjusterController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    enum adjustType {
        case addTime
        case removeTime
    }
    var adjustMode: adjustType = .addTime
    var pickerData: [[String]] = [[String]]()
    var task: Task?
    
    // MARK: Outlets
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var addRemoveSegmenter: UISegmentedControl!
    
    
    // MARK: Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var hours: [String] = []
        for n in 0...24 {
            hours.append(String(n))
        }
        pickerData.append(hours)
        
        var minutes: [String] = []
        for n in 0...59 {
            minutes.append(String(n))
        }
        pickerData.append(minutes)
        
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
    }
    
    
    // MARK: Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch addRemoveSegmenter.selectedSegmentIndex
        {
        case 0:
            adjustMode = .addTime
            print("add time")
        case 1:
            adjustMode = .removeTime
            print("remove Time")
        default:
            break
        }
    }
    
    @IBAction func cancelButton(sender: UIButton) {
        print("cancel")
        self.dismiss(animated: true)
    }
    
    @IBAction func submitButton(sender: UIButton) {
       
        let hourSelection = pickerData[0][timePicker.selectedRow(inComponent: 0)]
        let minuteSelection = pickerData[1][timePicker.selectedRow(inComponent: 1)]
        let adjustmentInSeconds = Double(hourSelection)! * 3600 + Double(minuteSelection)! * 60
        
        if adjustMode == .addTime {
            updateTime(adjustTimeInSeconds: adjustmentInSeconds, addTime: true)
        } else {
            updateTime(adjustTimeInSeconds: adjustmentInSeconds, addTime: false)
        }
        
        NotificationCenter.default.post(name: Notification.Name("didReceiveData"), object: nil)
        
        self.dismiss(animated: true)
    }
    
    // MARK: Picker Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch component {
        case 0:
            if self.timePicker.selectedRow(inComponent: 0) == row
            {
                return "\(pickerData[component][row]) hour(s)"
            }
            else
            {
                return pickerData[component][row]
            }
        case 1:
            if self.timePicker.selectedRow(inComponent: 1) == row
            {
                return "\(pickerData[component][row]) min(s)"
            }
            else
            {
                return pickerData[component][row]
            }

        default:

            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timePicker.reloadAllComponents()
    }
    
    // MARK: CoreData
    func updateTime(adjustTimeInSeconds: Double, addTime: Bool) {
        
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext =
        appDelegate.persistentContainer.viewContext

         // Fetch the current task
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskData")
        fetchRequest.predicate = NSPredicate(format: "name == %@", (task?.name)!)
              
        var tasks: [NSManagedObject] = []
        do{
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
              
        let currentTask = tasks.first
        
        // Calculate adjusted elapsed time
        let currentSecondsThisWeek: Double = (task?.elapsedSecondsThisWeek)!
        var adjustedSecondsThisWeek: Double = 0.0
        
        if addTime {
            
            adjustedSecondsThisWeek = currentSecondsThisWeek + adjustTimeInSeconds
            
        } else { // Remove time
            
            adjustedSecondsThisWeek = currentSecondsThisWeek - adjustTimeInSeconds
            
            // Adjusted time should not become a negative value
            if adjustedSecondsThisWeek < 0.0 {
                adjustedSecondsThisWeek = 0.0
            }
        }
        
        currentTask?.setValue(adjustedSecondsThisWeek, forKey: "elapsedSecondsThisWeek")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        print("Adjusted Time has been saved")
    }

}
