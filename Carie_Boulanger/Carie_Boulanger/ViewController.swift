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

class MainViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, DevicesTableViewControllerDelegate {
    
    var delegate: MainViewControllerDelegate?
    
    var values:Array<Message> = [];
    var selectedSensor:String = "";
    
    var deviceName:String = "" {
        didSet {
            if let d = delegate {
                d.collapseSidePanels!();
                refreshData();
            }
        }
    };
    var progressHUD = HTProgressHUD();
    @IBOutlet var TempSensorView: SensorOverview!;
    @IBOutlet var HumiditySensorView: SensorOverview!;
    @IBOutlet var ParticulesSensorView: SensorOverview!;
    @IBOutlet var LightSensorView: SensorOverview!;
    @IBOutlet var ChartView: JBLineChartView!;
    @IBOutlet var refreshButton:  UIButton!;
    
    @IBOutlet var UnitLabel: UILabel!;
    @IBOutlet var ValueLabel: UILabel!;
    @IBOutlet var dateLabel: UILabel!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressHUD.text = "Loading messages";
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.TempSensorView.title = "Temperature";
        self.HumiditySensorView.title = "Humidity";
        
        self.ChartView.dataSource = self;
        self.ChartView.delegate = self;
        
        self.clearChart();
        
        if deviceName == "" {
            if let D = delegate {
                D.toggleLeftPanel!();
            }
        }
        
        let selector4TapTemp:Selector = Selector("handleTapTemperature:");
        let selector4TapLight:Selector = Selector("handleTapLight:");
        let selector4TapHumidity:Selector = Selector("handleTapHumidity:");
        let selector4TapParticules:Selector = Selector("handleTapParticule:");
        
        let tapGestureRecognizerTemp = UITapGestureRecognizer(target: self, action: selector4TapTemp);
        let tapGestureRecognizerHumidity = UITapGestureRecognizer(target: self, action: selector4TapHumidity)
        let tapGestureRecognizerLight = UITapGestureRecognizer(target: self, action: selector4TapLight)
        let tapGestureRecognizerParticules = UITapGestureRecognizer(target: self, action: selector4TapParticules)
        
        self.TempSensorView.addGestureRecognizer(tapGestureRecognizerTemp);
        self.LightSensorView.addGestureRecognizer(tapGestureRecognizerLight);
        self.HumiditySensorView.addGestureRecognizer(tapGestureRecognizerHumidity);
        self.ParticulesSensorView.addGestureRecognizer(tapGestureRecognizerParticules);
    }
    
    @IBAction func showValue() {
        UnitLabel.hidden = false;
        ValueLabel.hidden = false;
    }
    
    @IBAction func hideValue() {
        UnitLabel.hidden = true;
        ValueLabel.hidden = true;
    }
    
    func prepareChartAndReload(unit:String) {
        UnitLabel.text = unit;
        ValueLabel.text = "";
        dateLabel.text = ""
        self.ChartView.reloadData();
        self.ChartView.userInteractionEnabled = true;
    }
    
    func clearChart() {
        UnitLabel.text = "";
        ValueLabel.text = "";
        dateLabel.text = ""
        self.ChartView.userInteractionEnabled = false;
    }
    
    func handleTapTemperature(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            NSLog("Tap Temp");
            selectedSensor = "Temperature";
            self.prepareChartAndReload("°C");
        }
    }
    
    func handleTapHumidity(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            NSLog("Tap Humidity");
            selectedSensor = "Humidity";
            self.prepareChartAndReload("%");
        }
    }
    
    func handleTapLight(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            NSLog("Tap Light");
            selectedSensor = "Light";
            self.prepareChartAndReload("Lux");
        }
    }
    
    func handleTapParticule(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            NSLog("Tap Particule");
            selectedSensor = "Particule";
            self.prepareChartAndReload("??")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshData() {

        self.clearChart();
        
        progressHUD.showInView(self.view);
        
        // Get current date.
        let dateRange:Int = -5;
        let date:NSDate = (dateRange.days).fromNow;
        
        //Format URL
        if let currentDate = DateTimeFormater.sharedInstance.dateStringFromDate(date)
        {
            if let url = NSURL(string: "http://prevention.azurewebsites.net/api/messages/" + deviceName + "/" + currentDate)
            {
                //let url = NSURL(string: "http://prevention.azurewebsites.net/api/messages/" + deviceName + "/2014-10-20");
                
                //Request data
                JSONService
                    .GET(url)
                    .success{json in {self.ParseJsonMessages(json)} ~> {self.UpdateValues($0)}}
                    .failure(self.onFailure, queue: NSOperationQueue.mainQueue())
            }
        }
    }
    
    // MARK: - Http request
    func UpdateValues (messages:[Message]) {
        progressHUD.hideWithAnimation(true);
        if messages.count == 0 {
            var alertView = UIAlertView(title: "No messages", message: "No message returned by the web service, consider selecting another device", delegate: nil, cancelButtonTitle: "Ok");
            
            alertView.show();
            
            if let D = delegate {
                D.toggleLeftPanel!();
            }
            
        } else {
            
            self.ChartView.minimumValue = 0;
            
            self.ChartView.reloadData();
            
            for item:Message in messages {
                values.append(item);
            }
            // Extract only the last 15 values for sparklines in Sensor views
            
            //Compute array bounds to slice
            let upperBound:Int = self.values.count - 1;
            
            if upperBound > 0 {
                var lowerBound:Int = upperBound - 15;
                
                // Ensure lower bound will not be negative
                lowerBound = lowerBound > -1 ? lowerBound:0;
                
                // Assign values to sparklines
                self.TempSensorView.values = Array(self.values[lowerBound...upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Temperature.value) };
                
                self.HumiditySensorView.values = Array(self.values[lowerBound...upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Humidite.value) };
                
                self.ParticulesSensorView.values = Array(self.values[lowerBound...upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Particules.value) };
                
                self.LightSensorView.values = Array(self.values[lowerBound...upperBound]).map { (item:Message) -> CGFloat in return CGFloat(item.Lumiere.value) };
                
                
            }
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
        return UInt(self.values.count);
    }
    
    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.blueColor();
    }
    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.redColor();
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.redColor();
    }
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        
        var Message = self.values[Int(horizontalIndex)];
        var value:CGFloat = 0;
        
        switch selectedSensor {
        case "Temperature":
            value = CGFloat(Message.Temperature.value);
            NSLog("Temperature at %u is " + value.description, horizontalIndex);
            break;
        case "Humidity":
            value = CGFloat(Message.Humidite.value);
            NSLog("Humidity at %u is " + value.description, horizontalIndex);
            break;
        case "Light":
            value = CGFloat(Message.Lumiere.value);
            NSLog("Light at %u is " + value.description, horizontalIndex);
            break;
        case "Particule":
            value = CGFloat(Message.Particules.value);
            NSLog("Particule at %u is " + value.description, horizontalIndex);
            break;
        default:
            break;
        }
        return value;
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
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt, touchPoint: CGPoint) {
        
        var message = self.values[Int(horizontalIndex)];
        var value:CGFloat = 0;
        
        switch selectedSensor {
        case "Tempareture":
            value = CGFloat(message.Temperature.value);
            NSLog("Temperature at %u is " + value.description, horizontalIndex);
            break;
        case "Humidity":
            value = CGFloat(message.Humidite.value);
            NSLog("Humidity at %u is " + value.description, horizontalIndex);
            break;
        case "Light":
            value = CGFloat(message.Lumiere.value);
            NSLog("Light at %u is " + value.description, horizontalIndex);
            break;
        case "Particule":
            value = CGFloat(message.Particules.value);
            NSLog("Particule at %u is " + value.description, horizontalIndex);
            break;
        default:
            break;
        }
        
        ValueLabel.text = value.description;
        dateLabel.text = message.DateStr;
    }
    
    //MARK: - DevicesTableViewControllerDelegate
    func didSelectDevice(deviceName: String) {
        self.deviceName = deviceName;
    }

}

 

