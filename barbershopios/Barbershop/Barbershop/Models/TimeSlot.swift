//
//  TimeSlot.swift
//  Barbershop
//
//  Created by user on 2017-05-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation

class TimeSlot : NSObject
{
    var day: [Int];
    
    override init()
    {
        self.day = Array(repeating: 1, count: 96);
        
    }

    func bookAppointment(startTime: Int, endTime: Int)
    {
        for i in startTime...endTime
        {
            day[i] = 2;
        }
    }
    
    func removeFromSchedule(startTime: Int, endTime: Int)
    {
        for i in startTime...endTime
        {
            day[i] = 1;
        }
    }

    
    func addToSchedule(startTime: Int, endTime: Int)
    {
        for i in startTime...endTime
        {
            day[i] = 0;
        }

    }

    func clearDate()
    {
        for i in 0...95
        {
            day[i] = 1;
        }
    }
    
    func getFirstTime() -> String
    {
        var i = 0;
        
        while (day[i] != 2)
        {
            i += 1;
        }
        
        return scheduleTimes[i - 1];
    }
    
    func getLastTime() -> String
    {
        var i = 0;
        var max = 0;
        
        while (i != 96)
        {
            if (day[i] == 2)
            {
                max = i;
            }
            
            i += 1;
        }
        
        return scheduleTimes[max - 1];
    }
    
    func getFirstReadableTime() -> String
    {
        var i = 0;
        
        while (day[i] != 2)
        {
            i += 1;
        }
        
        i += 1;
        
        return scheduleReadableTimes[i - 1];

    }
    
    func getLastReadableTime() -> String
    {
        var i = 0;
        var max = 0;
        
        while (i != 96)
        {
            if (day[i] == 2)
            {
                max = i;
            }
            
            i += 1;
        }
        
        return scheduleReadableTimes[max - 1];

    }
    
    func getReadableTimeAt(index: Int) -> String
    {
        return scheduleReadableTimes[index];
    }
    
    func getIndexFromReadableTime(_ time: String) -> Int
    {
        return scheduleReadableTimes.index(of: time)!;
    }
    
    func isAvailable(_ index: Int, _ length: Int) -> Bool
    {
        for i in index...(index + length)
        {
            if (day[i] != 0)
            {
                return false;
            }
        }
        return true;
    }
    
    func getNextAvailableReadableTime(_ index: Int) -> Int
    {
        for i in index...95
        {
            if (day[i] == 0)
            {
                print("\(i)");

                return i - 1;
            }
        }
        
        return getNextAvailableReadableTime(0);
    }
    
    private func intervalAmountForHour(amount: Int) -> Int
    {
        switch (amount) {
        case 15:
            return 1;
        case 30:
            return 2;
        case 45:
            return 3;
        default:
            return 0;
        }
    }
    
    func scheduleToString() -> String
    {
        var server_string = "";
        
        for i in day
        {
            server_string += "\(i)";
        }
        
        return server_string;
    }
    
    func stringToSchedule(string: String)
    {
        if (string.characters.count != 96)
        {
            return
        }
        
        for i in 0...95
        {
            day[i] = Int(string[i])!;
        }
    }
    
    func returnScheduleAsReadableString() -> String
    {
        var schedule = "";
        var valid = false;
        
        for i in 0...95
        {
            if (day[i] == 0 && valid == false)
            {
                schedule += getReadableTimeAt(index: i);
                valid = true;
            }
            else if (day[i] != 0 && valid == true)
            {
                schedule += " - " + getReadableTimeAt(index: i - 1) + ",";
                valid = false;
            }
        }
        
        return schedule;
    }
}
