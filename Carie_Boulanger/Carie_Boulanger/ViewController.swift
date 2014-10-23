//
//  ViewController.swift
//  Carie_Boulanger
//
//  Created by gregory delpu on 11/10/2014.
//  Copyright (c) 2014 Gregory DELPU. All rights reserved.
//

import UIKit

@objc
protocol MainViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func collapseSidePanels()
}

class MainViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource {
    var delegate: MainViewControllerDelegate?
    
    var values:Array<Message> = [];
    var ValuesForChart:Array<CGFloat> = [];
    
    @IBOutlet var TempSensorView: SensorOverview!;
    @IBOutlet var HumiditySensorView: SensorOverview!;
    @IBOutlet var ParticulesSensorView: SensorOverview!;
    @IBOutlet var LightSensorView: SensorOverview!;
    @IBOutlet var ChartView: JBLineChartView!;
    @IBOutlet var refreshButton:  UIButton!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.TempSensorView.title = "Temperature";
        self.HumiditySensorView.title = "Humidity";
        
        self.ChartView.dataSource = self;
        self.ChartView.delegate = self;
        
        self.refreshData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshData() {
        
        // Get current date.
        let date = NSDate();
        let formatter = NSDateFormatter();
        formatter.dateFormat = "YYYY-MM-dd";
        formatter.stringFromDate(date);
        
        //Format URL
            //let url = NSURL(string: "http://prevention.azurewebsites.net/api/messages/300D/" + formatter.stringFromDate(date));
        let url = NSURL(string: "http://prevention.azurewebsites.net/api/messages/86D3/" + "2014-10-01/2014-10-17");

        //Request data
        JSONService
            .GET(url!)
            .success{json in {self.ParseJsonMessages(json)} ~> {self.UpdateValues($0)}}
            .failure(self.onFailure, queue: NSOperationQueue.mainQueue())
    }
    
    // MARK: - Http request
    func UpdateValues (messages:[Message]) {
        self.ChartView.reloadData();
        
        for item:Message in messages {
            values.append(item);
        }
        // Extract only the last 15 values for sparklines in Sensor views
        
        //Compute array bounds to slice
        let upperBound:Int = self.values.count - 1;
        
        if upperBound > 0 {
            var lowerBound1:Int = upperBound - 50;
            var lowerBound:Int = upperBound - 10;
            
            // Ensure lower bound will not be negative
            lowerBound = lowerBound > -1 ? lowerBound:0;
            lowerBound1 = lowerBound1 > -1 ? lowerBound1:0;
            
            self.ValuesForChart = Array(self.values[lowerBound1 ... upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Temperature.value) };
        
            // Assign values to sparklines
            self.TempSensorView.values = Array(self.values[lowerBound...upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Temperature.value) };
            
            self.HumiditySensorView.values = Array(self.values[lowerBound...upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Humidite.value) };
            
            self.ParticulesSensorView.values = Array(self.values[lowerBound...upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Particules.value) };
            
            self.LightSensorView.values = Array(self.values[lowerBound...upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Lumiere.value) };
            
            
        }
    }
    
    func ParseJsonMessages (json: [JSON]) -> [Message] {
        
        var result:[Message] = [];
        values.removeAll(keepCapacity: false);
        
        // Parse every message and store it in the Messages array
        for item:JSON in json {
            var message:Message = Message(json: item);
            result.append(message);
        }
        
        return result;
    }
    
    private func onFailure(statusCode: Int, error: NSError?)
    {
        //Json service error handler.
        println("HTTP status code \(statusCode) Error: \(error)")
    }
    
    //MARK: JBLineChartView delegate
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(self.ValuesForChart.count);
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        
        var Temp = self.ValuesForChart[Int(horizontalIndex)];
        NSLog("Temperature at %u is " + Temp.description, horizontalIndex);
        return Temp;
    }
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.blueColor();
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 1;
    }
}

