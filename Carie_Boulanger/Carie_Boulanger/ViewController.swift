//
//  ViewController.swift
//  Carie_Boulanger
//
//  Created by gregory delpu on 11/10/2014.
//  Copyright (c) 2014 Gregory DELPU. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    var values:Array<CGFloat> = [];
    
    @IBOutlet var TempSensorView: SensorOverview!;
    @IBOutlet var refreshButton:  UIButton!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.refreshData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshData() {
        
        let url = NSURL(string: "http://prevention.azurewebsites.net/api/messages/300D/2014-10-02")
        
        JSONService
            .GET(url!)
            .success{json in {self.ParseJsonMessages(json)} ~> {self.UpdateValues($0)}}
            .failure(self.onFailure, queue: NSOperationQueue.mainQueue())
    }
    
    // MARK: - Http request
    func UpdateValues (messages:[CGFloat]) {
        
        TempSensorView.values = messages;
    }
    
    func ParseJsonMessages (json: [JSON]) -> [CGFloat] {
        
        var result:[CGFloat] = [];
        
        //        let dateFormatter: NSDateFormatter = NSDateFormatter();
        //        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";
        
        for item:JSON in json {
            result.append(CGFloat(item["Temperature"].integerValue!));
            
            var test:NSDate = DateTimeFormater.sharedInstance.dateFromString(item["Date"].stringValue!)!;
        }
        
        return result;
    }
    
    private func onFailure(statusCode: Int, error: NSError?)
    {
        println("HTTP status code \(statusCode) Error: \(error)")
    }
}

