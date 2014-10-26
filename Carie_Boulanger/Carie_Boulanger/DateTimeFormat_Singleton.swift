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
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";
        
    }
    
    func dateFromString(dateString: String) -> NSDate? {
        return dateFormatter.dateFromString(dateString);
    }

}