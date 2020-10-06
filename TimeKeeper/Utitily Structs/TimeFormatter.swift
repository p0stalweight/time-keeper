//
//  TimeFormatter.swift
//  TimeKeeper
//
//  Created by John Postlewaite on 6/27/20.
//  Copyright © 2020 John Postlewaite. All rights reserved.
//

import Foundation

struct TimeFormatter {
    
    func convertHoursToHoursAndMinutes(hours: Double) -> String {
        let totalMinutes: Int = Int(hours * 60)
        let displayedMinutes: Int = totalMinutes % 60
        let displayedHours: Int = totalMinutes / 60
        
        var hourDisplayStr = String(displayedHours)
        var hourStr = "hours"
        if displayedHours == 0 && displayedMinutes == 0 {
            return "0 minutes"
        }
        
        if displayedHours == 1 {
            hourStr = "hour"
        } else if displayedHours == 0 {
            hourStr = ""
            hourDisplayStr = ""
        }
        
        var minuteStr = "minutes"
        var minuteDisplayStr = String(displayedMinutes)
        if displayedMinutes == 1 {
            minuteStr = "minute"
        } else if displayedMinutes == 0 {
            minuteStr = ""
            minuteDisplayStr = ""
        }
        
        return "\(hourDisplayStr) \(hourStr) \(minuteDisplayStr) \(minuteStr)"
    }
    
    func convertToDisplayString (elapsedTimeInSeconds : Int) -> String {
       
        let displayedSeconds = elapsedTimeInSeconds % 60
        let displayedHours : Int = elapsedTimeInSeconds / 3600
        let displayedMinutes : Int = (elapsedTimeInSeconds % 3600) / 60
        var result = String(displayedHours) + ":"
        
        if displayedMinutes < 10 {
            result += "0" + String(displayedMinutes)
        }
        else{
            result += String(displayedMinutes)
        }
        
        if displayedSeconds < 10 {
            result += ":0" + String(displayedSeconds)
        }
        else{
           result += ":" + String(displayedSeconds)
        }
        
        return result
    }
    
}
