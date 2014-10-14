//
//  JSON.swift
//  SwiftPlaces
//
//  Created by Joshua Smith on 7/28/14.
//  Copyright (c) 2014 iJoshSmith. All rights reserved.
//

import Foundation

/** All possible outputs of the JSONObjectWithData function. */
enum JSONObjectWithDataResult
{
    case Success([JSON])
    case Failure(NSError)
}

/**
Attempts to convert the specified data object to JSON data
objects and returns either the root JSON object or an error.
*/
func JSONObjectWithData(
    data:    NSData,
    options: NSJSONReadingOptions = nil)
    -> JSONObjectWithDataResult
{
    var error: NSError?
    
//    let json1: Array<String> = NSJSONSerialization.JSONObjectWithData(
//        data,
//        options: NSJSONReadingOptions(0),
//        error:  &error) as Array<String>;
    
    var dataTxt = NSString(data: data, encoding: NSUTF8StringEncoding)
    
    //NSLog("\(dataTxt)")
    var json = JSON(data: data, options: NSJSONReadingOptions(0), error: &error)
    
    if let test:Array<JSON> = json.arrayValue {
        return .Success(test)

    }
    
    return .Failure(error ?? NSError())
}