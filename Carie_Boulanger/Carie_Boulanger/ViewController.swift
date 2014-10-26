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

class MainViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, DevicesTableViewControllerDelegate, SensorOverviewDelegate {
    
    var delegate: MainViewControllerDelegate?
    
    var values:Array<Message> = [];
    var ValuesForChart:Array<CGFloat> = [];
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressHUD.text = "Loading messages";
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.TempSensorView.title = "Temperature";
        self.HumiditySensorView.title = "Humidity";
        
        self.TempSensorView.delegate = self;
        self.LightSensorView.delegate = self;
        self.HumiditySensorView.delegate = self;
        
        self.ChartView.dataSource = self;
        self.ChartView.delegate = self;
        
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
    
    func handleTapTemperature(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            NSLog("Tap Temp");
            selectedSensor = "Temperature";
            UnitLabel.text = "°C";
            ValueLabel.text = "";
            self.ChartView.reloadData();
        }
    }
    
    func handleTapHumidity(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            NSLog("Tap Humidity");
            selectedSensor = "Humidity";
            UnitLabel.text = "%";
            ValueLabel.text = "";
            self.ChartView.reloadData();
        }
    }
    
    func handleTapLight(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            NSLog("Tap Light");
            selectedSensor = "Light";
            UnitLabel.text = "Lux";
            ValueLabel.text = "";
            self.ChartView.reloadData();
            
        }
    }
    
    func handleTapParticule(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            NSLog("Tap Particule");
            selectedSensor = "Particule";
            UnitLabel.text = "??";
            ValueLabel.text = "";
            self.ChartView.reloadData();
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshData() {
        progressHUD.showInView(self.view);
        // Get current date.
        let date = NSDate();
        let formatter = NSDateFormatter();
        formatter.dateFormat = "YYYY-MM-dd";
        formatter.stringFromDate(date);
        
        //Format URL
        let url = NSURL(string: "http://prevention.azurewebsites.net/api/messages/" + deviceName + "/" + formatter.stringFromDate(date));
        
        //let url = NSURL(string: "http://prevention.azurewebsites.net/api/messages/" + deviceName + "/2014-10-20");
        
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
        progressHUD.hideWithAnimation(true);
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
        
        var Message = self.values[Int(horizontalIndex)];
        var value:CGFloat = 0;
        
        switch selectedSensor {
        case "Tempareture":
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
        
        var Message = self.values[Int(horizontalIndex)];
        var value:CGFloat = 0;
        
        switch selectedSensor {
        case "Tempareture":
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
        
        ValueLabel.text = value.description;
    }
    
    //MARK: - DevicesTableViewControllerDelegate
    func didSelectDevice(deviceName: String) {
        self.deviceName = deviceName;
    }
    
    func DidTouchLogo(SensorTitle: String) {
        selectedSensor = SensorTitle;
        
        
        self.ChartView.reloadData()
        
        
    }
}

