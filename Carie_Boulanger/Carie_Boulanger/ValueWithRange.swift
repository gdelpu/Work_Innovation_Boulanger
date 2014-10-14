//
//  ValueWithRange.swift
//  Prevention Boulanger
//
//  Created by gregory delpu on 04/10/2014.
//  Copyright (c) 2014 Gregory DELPU. All rights reserved.
//

import Foundation

public class ValueWithRange {
    
    public var value:Int;
    public var valueMax:Int;
    public var valueMin:Int;
    
    public init(value:Int, valueMax:Int, valueMin:Int) {
        self.value = value;
        self.valueMax = valueMax;
        self.valueMin = valueMin;
    }
}