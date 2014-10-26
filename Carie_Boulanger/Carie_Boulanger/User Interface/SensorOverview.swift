//
//  SensorOverview.swift
//  Carie_Boulanger
//
//  Created by gregory delpu on 11/10/2014.
//  Copyright (c) 2014 Gregory DELPU. All rights reserved.
//

import UIKit
import QuartzCore

@objc
protocol SensorOverviewDelegate {
    optional func DidTouchLogo(SensorTitle: String)
}

@IBDesignable
class SensorOverview: UIView, JBLineChartViewDataSource, JBLineChartViewDelegate  {
    
    let BorderWidth = CGFloat(2);
    let lineColor = UIColor.blueColor();
    
    @IBOutlet weak var sensorLogo: UIImageView!;
    
    @IBOutlet weak var colorRing: UIView!;
    @IBOutlet weak var borderView: UIView!;
    @IBOutlet weak var placeHolderView: UIView!;
    
    @IBOutlet weak var titleLabel: UILabel!;
    @IBOutlet weak var valueLabel: UILabel!;
    
    @IBOutlet weak var ChartView: JBLineChartView!;
    @IBOutlet weak var ChartBackground: UIView!;
    
    @IBOutlet weak var buttonSelect: UIButton!;
    
    var delegate:SensorOverviewDelegate?;
    
    private var proxyView: SensorOverview?
    
    @IBInspectable var title: String = "" {
        didSet {
            self.proxyView!.titleLabel.text = title
        }
    }
    
    var values:[CGFloat] = [] {
        didSet {
            self.proxyView!.values = self.values;
            self.valueLabel.text = self.values.last?.description;
            self.drawChart();
        }
    }
    
    @IBInspectable  var avatarImage: UIImage = UIImage() {
        didSet {
            let size = self.avatarImage.size
            let rect = CGRectMake(0, 0, size.width, size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            
            var path = UIBezierPath(ovalInRect: rect)
            path.addClip()
            self.avatarImage.drawInRect(rect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.proxyView!.sensorLogo.image = image
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame);
        var view = self.loadNib();
        view.frame = self.bounds;
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight;
        
        self.addSubview(self.proxyView!);
        
        initPlot();
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        if self.subviews.count == 0 {
            var view = self.loadNib()
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            let contraints = self.constraints()
            self.removeConstraints(contraints)
            view.addConstraints(contraints)
            
            view.proxyView = view
            
            //            let selector4Tap:Selector = Selector("handleTap:");
            //            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector4Tap);
            //            view.proxyView?.addGestureRecognizer(tapGestureRecognizer);
            return view
        }
        return self
    }
    
    override func awakeFromNib() {
        self.drawChart();
    }
    
    private func loadNib() -> SensorOverview {
        let bundle = NSBundle(forClass: self.dynamicType)
        var view = bundle.loadNibNamed("SensorView", owner: nil, options: nil)[0] as SensorOverview
        
        var borderLayer = view.borderView.layer;
        borderLayer.cornerRadius = 10;
        borderLayer.borderWidth = BorderWidth;
        borderLayer.borderColor = UIColor.darkGrayColor().CGColor;
        borderLayer.shadowOffset = CGSize(width: 0.2, height: -0.5);
        borderLayer.shadowOpacity = 0.5;
        
        var colorRingLayer = view.colorRing.layer;
        colorRingLayer.cornerRadius = view.colorRing.frame.width/2;
        colorRingLayer.shadowOffset = CGSize(width: 0.2, height: -0.5);
        colorRingLayer.shadowOpacity = 0.5
        
        var placeHolderLayer = view.placeHolderView.layer;
        placeHolderLayer.cornerRadius = view.placeHolderView.frame.width/2;
        placeHolderLayer.borderColor = UIColor.darkGrayColor().CGColor;
        placeHolderLayer.borderWidth = BorderWidth;
        
        var imageLayer = view.sensorLogo.layer;
        
        imageLayer.cornerRadius = view.sensorLogo.frame.width/2;
        imageLayer.borderWidth = BorderWidth;
        imageLayer.borderColor = UIColor.darkGrayColor().CGColor;
        imageLayer.shadowOffset = CGSize(width: 0.2, height: -0.5);
        imageLayer.shadowOpacity = 0.5;
        
        //view.sensorLogo.hidden = true;
        view.userInteractionEnabled = true;
        
        return view
    }
    
    @IBAction func handleTap() {
        if let D = self.delegate {
            var title :String = self.title;
            D.DidTouchLogo?(title);
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        var height:CGFloat = 0;
        
        height = height + self.borderView.frame.size.height + (self.colorRing.frame.height/2);
        
        return CGSize(width: 10, height: height);
    }
    
    func initPlot() {
        self.ChartView.delegate = self;
        self.ChartView.dataSource = self;
        self.ChartView.showsVerticalSelection = false;
        self.ChartView.backgroundColor = UIColor.clearColor();
    }
    
    func drawChart() {
        if self.ChartView.delegate == nil {
            initPlot();
        }
        if values.count != 0 {
            var range = max(values)! - min(values)!;
            range = range * 0.1;
            
            range = min(values)! - range;
            
            range = range > 0 ? range : 0;
            
            
            
            self.ChartView.minimumValue = range;
            self.ChartView.reloadData();
            self.ChartView.hidden = false;
        } else {
            self.ChartView.hidden = true;
        }
    }
    
    //MARK: - JBBarChartView Delegate
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, dotRadiusForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return 5;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 2;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return lineColor;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return lineColor;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return lineColor;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return lineColor;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, lineStyleForLineAtLineIndex lineIndex: UInt) -> JBLineChartViewLineStyle {
        return JBLineChartViewLineStyle.Solid
    }
    
    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.clearColor();
    }
    
    //MARK: - JBBarChartView DataSource
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt( values.count );
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return values[Int(horizontalIndex)];
    }
    
    //MARK: - Helper functions
    func min <T : Comparable> (var array : [T]) -> T? {
        if array.isEmpty {
            return nil
        }
        return reduce(array, array[0]) {$0 > $1 ? $1 : $0}
    }
    
    func max <T : Comparable> (var array : [T]) -> T? {
        if array.isEmpty {
            return nil
        }
        return reduce(array, array[0]) {$0 < $1 ? $1 : $0}
    }
    
    
}
