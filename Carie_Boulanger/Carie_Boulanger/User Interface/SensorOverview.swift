//
//  SensorOverview.swift
//  Carie_Boulanger
//
//  Created by gregory delpu on 11/10/2014.
//  Copyright (c) 2014 Gregory DELPU. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class SensorOverview: UIView, JBLineChartViewDataSource, JBLineChartViewDelegate  {
    
    let BorderWidth = CGFloat(2);
    
    
    @IBOutlet weak var sensorLogo: UIImageView!;
    
    @IBOutlet weak var colorRing: UIView!;
    @IBOutlet weak var borderView: UIView!;
    @IBOutlet weak var placeHolderView: UIView!;
    
    @IBOutlet weak var titleLabel: UILabel!;
    @IBOutlet weak var valueLabel: UILabel!;
    
    @IBOutlet weak var ChartView: JBLineChartView!;
    @IBOutlet weak var ChartBackground: UIView!;
    
    private var proxyView: SensorOverview?
    
    @IBInspectable var title: String = "" {
        didSet {
            self.proxyView!.titleLabel.text = title
        }
    }
    
    var values:[CGFloat] = [5,5,5,5] {
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
        super.init(frame: frame)
        
        var view = self.loadNib()
        view.frame = self.bounds
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.proxyView = view
        self.addSubview(self.proxyView!)
        
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
        
        var colorRingLayer = view.colorRing.layer;
        colorRingLayer.cornerRadius = view.colorRing.frame.width/2;
        
        var placeHolderLayer = view.placeHolderView.layer;
        placeHolderLayer.cornerRadius = view.placeHolderView.frame.width/2;
        placeHolderLayer.borderColor = UIColor.darkGrayColor().CGColor;
        placeHolderLayer.borderWidth = BorderWidth;
        
        var imageLayer = view.sensorLogo.layer;
        
        imageLayer.cornerRadius = view.sensorLogo.frame.width/2;
        imageLayer.borderWidth = BorderWidth;
        imageLayer.borderColor = UIColor.darkGrayColor().CGColor;
        
        view.userInteractionEnabled = true;
        
        return view
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
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
    }
    
    func drawChart() {
        if self.ChartView.delegate == nil {
            initPlot();
        }
        self.ChartView.minimumValue = 0;
        self.test();
        self.ChartView.reloadData();
    }
    
    //MARK: - JBBarChartView Delegate
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 1;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.blueColor();
    }
    
    func lineChartView(lineChartView: JBLineChartView!, lineStyleForLineAtLineIndex lineIndex: UInt) -> JBLineChartViewLineStyle {
        return JBLineChartViewLineStyle.Solid
    }
    
    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(red: 119, green: 160, blue: 229, alpha: 0.5);
    }
    
    //MARK: - JBBarChartView DataSource
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt( values.count );
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return values[Int(horizontalIndex)];
    }
    
    func test () {
        let rect : CGRect = self.ChartBackground.frame
        var vista : UIView = UIView(frame: rect);
        
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = vista.bounds
        
        let cor1 = UIColor.redColor().CGColor
        let cor2 = UIColor.whiteColor().CGColor
        let arrayColors = [cor2, cor2, cor1]
        
        gradient.colors = arrayColors
        gradient.locations = [0.4, 0.6];
        
        self.ChartBackground.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func radialGradientImage(size:CGSize, start:CGFloat, end:CGFloat, center:CGPoint, radius:CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, true, 1);
        let num_location:UInt = 2;
        
        let locations:[CGFloat]  = [0.0, 1.0];
        let components:[CGFloat] = [start, start,start, 1.0, end, end, end, 1.0];
        
        var myColorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB();
        var myGradient:CGGradientRef = CGGradientCreateWithColorComponents(myColorSpace, components, locations, num_location);
        
        var myCentrePoint:CGPoint = CGPointMake(center.x * size.width, center.y * size.height);
        var myRadius:CGFloat = min(size.width, size.height)*radius;
        
        CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(), myGradient, myCentrePoint, 0, myCentrePoint, myRadius, CGGradientDrawingOptions.allZeros);
        
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return image;
    }
    
    func makeGradient() {
        var gradient:CAGradientLayer = CAGradientLayer();
        gradient.frame = self.ChartBackground.frame;
        gradient.colors = [UIColor.blueColor(), UIColor.clearColor()];
        self.ChartBackground.layer.insertSublayer(gradient, atIndex: 0);
    }
}
