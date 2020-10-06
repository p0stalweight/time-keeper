//
//  TaskViewController.swift
//  TimeKeeper
//
//  Created by John Postlewaite on 5/26/20.
//  Copyright © 2020 John Postlewaite. All rights reserved.
//

import UIKit
import CoreData

class TaskBuilderController: UIViewController {
    
    // MARK: Properties
    var task: Task?
   
    // MARK: Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var activityNameTextField: UITextField!
    @IBOutlet weak var hoursPerWeekTextField: UITextField!
       
    // MARK: Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else{
            print("Save button was not pressed, cancelling")
            return
        }
        
        let name = activityNameTextField.text ?? ""
        let secondsInAnHour: Double = 3600
        let hoursPerWeekGoal = Double(hoursPerWeekTextField.text!)!
        let weeklyGoalTimeInSeconds: Double? = hoursPerWeekGoal * secondsInAnHour
        save(name: name, weeklyGoalTimeInSeconds: weeklyGoalTimeInSeconds!)
        task = Task(name: name, weeklyGoalTimeInSeconds: weeklyGoalTimeInSeconds!, clockInDate: nil)
    }
    
    
    func save(name: String, weeklyGoalTimeInSeconds: Double) {
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext =
        appDelegate.persistentContainer.viewContext

        let entity =
        NSEntityDescription.entity(forEntityName: "TaskData",
                                   in: managedContext)!

        let currentTask = NSManagedObject(entity: entity,
                                   insertInto: managedContext)

        currentTask.setValue(name, forKeyPath: "name")
        currentTask.setValue(0.0, forKeyPath: "elapsedSecondsThisWeek")
        currentTask.setValue(weeklyGoalTimeInSeconds, forKeyPath: "weeklyGoalTimeInSeconds")
        currentTask.setValue(false, forKeyPath: "clockedIn")
        currentTask.setValue(nil, forKeyPath: "clockInDate")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}
