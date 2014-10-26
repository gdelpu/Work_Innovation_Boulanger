//
//  Extensions.swift
//  Carie_Boulanger
//
//  Created by gregory delpu on 26/10/2014.
//  Copyright (c) 2014 Gregory DELPU. All rights reserved.
//

import Foundation

extension Int {
    var days: NSDateComponents {
        let comps = NSDateComponents()
        comps.day = self;
        return comps
    }
}

extension NSDateComponents {
    var fromNow: NSDate {
        let cal = NSCalendar.currentCalendar()
        return cal.dateByAddingComponents(self, toDate: NSDate(), options: nil)!
    }
}

