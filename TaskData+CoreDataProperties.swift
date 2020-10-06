//
//  TaskData+CoreDataProperties.swift
//  TimeKeeper
//
//  Created by John Postlewaite on 9/22/20.
//  Copyright © 2020 John Postlewaite. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskData> {
        return NSFetchRequest<TaskData>(entityName: "TaskData")
    }

    @NSManaged public var clockedIn: Bool
    @NSManaged public var clockInDate: Date?
    @NSManaged public var elapsedSecondsThisWeek: Double
    @NSManaged public var name: String?
    @NSManaged public var weeklyGoalTimeInSeconds: Double

}

extension TaskData : Identifiable {

}
