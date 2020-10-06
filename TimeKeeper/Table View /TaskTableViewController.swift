//
//  TaskTableViewController.swift
//  TimeKeeper
//
//  Created by John Postlewaite on 6/12/20.
//  Copyright © 2020 John Postlewaite. All rights reserved.
//

import UIKit
import CoreData


class TaskTableViewController: UITableViewController {
    
    var tasks: [NSManagedObject] = []
    let secondsInHour: Double = 3600
   
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!

    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        self.updateTasks()
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.updateTasks()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            managedContext.delete(task)
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else{
            fatalError("the cell is not a TaskTableViewCell")
        }
        
        let task = tasks[indexPath.row]
        
        let tf = TimeFormatter()
        
        cell.nameLabel.text = task.value(forKeyPath: "name") as? String
        
        let goalHours = (task.value(forKeyPath: "weeklyGoalTimeInSeconds") as! Double) / secondsInHour
        cell.hoursLabel.text = tf.convertHoursToHoursAndMinutes(hours: goalHours)

        let elapsedHours = (task.value(forKeyPath: "elapsedSecondsThisWeek") as! Double) / secondsInHour
        cell.elapsedHoursLabel.text = tf.convertHoursToHoursAndMinutes(hours: elapsedHours)
        
        let weeklyProgress = Float(elapsedHours / goalHours)
        
        if weeklyProgress >= 1.0 {
            cell.hourProgressBar.progress = 1.0
        }else {
            cell.hourProgressBar.progress = weeklyProgress
        }
            
        return cell
    }
    
    // MARK: CoreData methods
    func updateTasks(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskData")
        
        do{
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print ("Unable to save. \(error), \(error.userInfo)")
        }
    
    }

    
    // MARK: Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? ""){
            
        case "addTask":
        
        print("Adding Task")
            
        case "showDetail":
            
        guard let taskController = segue.destination as? TaskController else{
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedtaskCell = sender as? TaskTableViewCell else{
            fatalError("Unexpected sender: \(sender ?? "")")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedtaskCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
            
        let selectedTask = tasks[indexPath.row]
        let sentTask = Task(name: selectedTask.value(forKeyPath: "name") as! String, elapsedSecondsThisWeek: selectedTask.value(forKey: "elapsedSecondsThisWeek") as! Double, weeklyGoalTimeInSeconds: selectedTask.value(forKeyPath: "weeklyGoalTimeInSeconds") as! Double, clockedIn: selectedTask.value(forKeyPath: "clockedIn") as! Bool, clockInDate: selectedTask.value(forKeyPath: "clockInDate") as! Date?)
        taskController.task = sentTask
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }
    
}
