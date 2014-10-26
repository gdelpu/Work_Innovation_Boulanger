//
//  DateTimeFormat_Singleton.swift
//  Carie_Boulanger
//
//  Created by gregory delpu on 14/10/2014.
//  Copyright (c) 2014 Gregory DELPU. All rights reserved.
//

import Foundation

//NSDateFormatter threadSafe static class using singleton pattern
// => Avoid instancing a dateformatter each time to speedup the application
// overhall performance.

class DateTimeFormater {
    class var sharedInstance :DateTimeFormater {
        struct Singleton {
            static let instance = DateTimeFormater()
        }
        
        return Singleton.instance
    }
    
    let dateFormatter: NSDateFormatter = NSDateFormatter();
    
    init() {
        
        
        
    }
    
    func dateFromString(dateString: String) -> NSDate? {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";
        return dateFormatter.dateFromString(dateString);
    }
    
    func dateStringFromDate(date:NSDate) -> String? {
        dateFormatter.dateFormat = "YYYY-MM-dd";
        return dateFormatter.stringFromDate(date);
    }
    
    func dateTimeStringFromDate(date:NSDate) -> String? {
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm";
        return dateFormatter.stringFromDate(date);
    }

}