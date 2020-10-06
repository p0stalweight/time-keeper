//
//  ViewController.swift
//  TimeKeeper
//
//  Created by John Postlewaite on 5/25/20.
//  Copyright © 2020 John Postlewaite. All rights reserved.
//

import UIKit
import CoreData

class TaskController: UIViewController {
    
    // MARK: Properties
    var timer = Timer()
    var timeInSeconds: Int = 0
    var progressFlag = false
    var task: Task? {
        didSet{
            navigationItem.title = task?.name!
        }
    }
    
    let secondsInHour: Double = 3600
    
    // MARK: Outlets
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var timeDisplayLabel: UILabel!
    @IBOutlet weak var storedTimeDisplayLabel: UILabel! 
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var inButton: UIButton!
    @IBOutlet weak var outButton: UIButton!
    @IBOutlet weak var goalTimeLabel: UILabel!
    
    
    // MARK: ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create outline around buttons
        inButton.layer.borderWidth = 1
        inButton.layer.cornerRadius = 5
        inButton.layer.borderColor = UIColor.black.cgColor
        
        outButton.layer.borderWidth = 1
        outButton.layer.cornerRadius = 5
        outButton.layer.borderColor = UIColor.black.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(didComeBack), name: Notification.Name("didComeBack"), object: nil)
        
        // Create a notification to update timer if app goes into the background
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData), name: Notification.Name("didReceiveData"), object: nil)
        
        // Update timer if previously clocked in
        if task!.clockedIn {
            updateTimer(startTimer: true)
            print("timerupdated")
        }
        
        updateUI()
    }

    
    func updateUI() {
        // Progress Bar Setup
        let currentProgress = Float((task!.elapsedSecondsThisWeek! + Double(timeInSeconds)) / task!.weeklyGoalTimeInSeconds!)
        progressBar.setProgress(currentProgress, animated: true)
        
        if currentProgress < 0.5{
            progressBar.progressTintColor = UIColor.red
        }
        else{
            progressBar.progressTintColor = UIColor.green
        }
        
        // Set task displayed attributes
        if let task = task {
            taskNameLabel.text = task.name
            goalTimeLabel.text = "Weekly Goal: " + String(Int(task.weeklyGoalTimeInSeconds! / secondsInHour)) + " hours"
            
            let elapsedSeconds = Int(task.elapsedSecondsThisWeek! + Double(timeInSeconds))
            let tf = TimeFormatter()
            storedTimeDisplayLabel.text = tf.convertToDisplayString(elapsedTimeInSeconds: elapsedSeconds)
        }else{
            fatalError("Invalid or nil task object")
        }
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        self.task = updateTask(task: task!)
        updateUI()
    }
    
    @objc func didComeBack(_ notification:Notification) {
        print("cameBack")
        if task!.clockedIn{
            let secondsSinceClockedIn = Double((task?.clockInDate!.timeIntervalSinceNow)! * -1)
            timeInSeconds = Int(secondsSinceClockedIn)
        }
        updateUI()
    }
    
    // MARK: Actions
    fileprivate func clockIn() {
        if !task!.clockedIn {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerPing), userInfo: nil, repeats: true)
            task!.clockedIn = true
            let startDate = Date()
            save(name: task!.name!, elapsedSeconds: task!.elapsedSecondsThisWeek!, clockedIn: true, clockInDate: startDate)
            task!.clockInDate = startDate
        }
    }
    
    @IBAction func clockInButton(_ sender: Any) {
        clockIn()
    }
    
    fileprivate func clockOut() {
        if task!.clockedIn {
            timer.invalidate()
            timeDisplayLabel.text = "0:00:00"
            task!.clockedIn = false
            timeInSeconds = 0
            
            // Record current session length
            var sessionInSeconds = Double((task?.clockInDate!.timeIntervalSinceNow)! * -1)
            sessionInSeconds = Double(round(1000 * sessionInSeconds) / 1000)
            task!.elapsedSecondsThisWeek! += sessionInSeconds
            
            // Change stored time label
            let tf = TimeFormatter()
            storedTimeDisplayLabel.text = tf.convertToDisplayString(elapsedTimeInSeconds: Int(task!.elapsedSecondsThisWeek!))
            
            
            // Save new time with Core Data
            save(name: task!.name!, elapsedSeconds: task!.elapsedSecondsThisWeek!, clockedIn: false, clockInDate: nil)
            
            if progressBar.progress < 1.0 {
                let currentProgress = Float(task!.elapsedSecondsThisWeek! / task!.weeklyGoalTimeInSeconds!)
                progressBar.setProgress(currentProgress, animated: true)
            }
            if !progressFlag && progressBar.progress > 0.5{
                progressBar.progressTintColor = UIColor.green
                progressFlag = true
            }
        }
    }
    
    @IBAction func clockOutButton(_ sender: Any) {
        clockOut()
    }
        
    @IBAction func adjustTimeButton(_ sender: Any) {
        print("segue to adjustment page")
    }
    
    @objc func timerPing (){
        timeInSeconds += 1
        let tf = TimeFormatter()
        timeDisplayLabel.text = tf.convertToDisplayString(elapsedTimeInSeconds: timeInSeconds)
    }
    
    func save(name: String, elapsedSeconds: Double, clockedIn: Bool, clockInDate: Date?) {
        // Get managed context
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        // Fetch the current task
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskData")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        var tasks: [NSManagedObject] = []
        do{
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // Update the elapsed hours
        let currentTask = tasks[0]
        currentTask.setValue(elapsedSeconds, forKeyPath: "elapsedSecondsThisWeek")
        currentTask.setValue(clockedIn, forKeyPath: "clockedIn")
        currentTask.setValue(clockInDate, forKeyPath: "clockInDate")

        // Save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateTimer(startTimer: Bool) {
        if task!.clockedIn {
            timeInSeconds = Int((task?.clockInDate!.timeIntervalSinceNow)! * -1)
            let tf = TimeFormatter()
            timeDisplayLabel.text = tf.convertToDisplayString(elapsedTimeInSeconds: timeInSeconds)
            if startTimer {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerPing), userInfo: nil, repeats: true)
                
            }
        }
    }
    
    //MARK: CoreData
    func updateTask(task: Task) -> Task {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return task
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskData")
        
        fetchRequest.predicate = NSPredicate(format: "name == %@", task.name!)
        
        var tasks = [NSManagedObject]()
        
        do{
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print ("Unable to save. \(error), \(error.userInfo)")
        }
        let convertedTasks = tasks as! [TaskData]
        let updatedTask = convertedTasks.first
        let resultTask = Task(name: updatedTask!.name!, elapsedSecondsThisWeek: updatedTask!.elapsedSecondsThisWeek, weeklyGoalTimeInSeconds: updatedTask!.weeklyGoalTimeInSeconds, clockedIn: updatedTask!.clockedIn, clockInDate: updatedTask!.clockInDate ?? Date())
        return resultTask!
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "TimeAdjustSegue" {
            guard let adjusterController = segue.destination as? AdjusterController else{
                      fatalError("Unexpected destination: \(segue.destination)")
            }
            adjusterController.task = task
        } else {
            fatalError("Invalid segue")
        }
    }
    
 

}

