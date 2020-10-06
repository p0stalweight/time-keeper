//
//  Activity.swift
//  TimeKeeper
//
//  Created by John Postlewaite on 5/26/20.
//  Copyright © 2020 John Postlewaite. All rights reserved.
//

import UIKit

struct Task {
    
    // MARK: Properties
    var name: String?
    var elapsedSecondsThisWeek: Double?
    var weeklyGoalTimeInSeconds: Double?
    var clockedIn: Bool
    var clockInDate: Date?
    
    // MARK: Initializers    
    init?(name: String, elapsedSecondsThisWeek: Double = 0.0, weeklyGoalTimeInSeconds: Double, clockedIn: Bool = false, clockInDate: Date?){
        guard !name.isEmpty else {
            return nil
        }
        guard (weeklyGoalTimeInSeconds > 0.0) else{
            return nil
        }
        self.name = name
        self.elapsedSecondsThisWeek = elapsedSecondsThisWeek
        self.weeklyGoalTimeInSeconds = weeklyGoalTimeInSeconds
        self.clockedIn = clockedIn
        self.clockInDate = clockInDate
    }
}
