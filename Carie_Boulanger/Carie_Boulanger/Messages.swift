//
//  Messages.swift
//  Prevention Boulanger
//
//  Created by gregory delpu on 03/10/2014.
//  Copyright (c) 2014 Gregory DELPU. All rights reserved.
//

import Foundation

public class Message {
    
    //public var Id:Int;
    //public var Date:NSDate;
    //public var Module:String;
    //public var Signal:Int;
    public var Temperature:ValueWithRange;
    public var Humidite:ValueWithRange;
    public var Particules:ValueWithRange;
    public var Lumiere:ValueWithRange;
    public var Date:NSDate!;
    public var DateStr:String!;
    
    public init(json: JSON){
        var value:Int, valueMax:Int, valueMin:Int;
        
        
        if let datestr = json["Date"].stringValue {
            if var myDate = DateTimeFormater.sharedInstance.dateFromString(datestr)
            {
                self.Date = myDate;
                self.DateStr = DateTimeFormater.sharedInstance.dateTimeStringFromDate(self.Date);
            }
        }
        
        value     = json["Temperature"].integerValue!;
        valueMax  = json["TemperatureMax"].integerValue!;
        valueMin  = json["TemperatureMin"].integerValue!;
        
        self.Temperature = ValueWithRange(value: value, valueMax: valueMax, valueMin: valueMin);
        
        value     = json["Humidite"].integerValue!;
        valueMax  = json["HumiditeMax"].integerValue!;
        valueMin  = json["HumiditeMin"].integerValue!;
        
        self.Humidite = ValueWithRange(value: value, valueMax: valueMax, valueMin: valueMin);

        value     = json["Particules"].integerValue!;
        valueMax  = json["ParticulesMax"].integerValue!;
        valueMin  = json["ParticulesMin"].integerValue!;
        
        self.Particules = ValueWithRange(value: value, valueMax: valueMax, valueMin: valueMin);
        
        value     = json["Lumiere"].integerValue!;
        valueMax  = json["LumiereMax"].integerValue!;
        valueMin  = json["LumiereMin"].integerValue!;
        
        self.Lumiere = ValueWithRange(value: value, valueMax: valueMax, valueMin: valueMin);
    }
}