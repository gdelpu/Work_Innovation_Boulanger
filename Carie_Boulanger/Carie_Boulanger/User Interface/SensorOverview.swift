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
class SensorOverview: UIView, JBBarChartViewDataSource, JBBarChartViewDelegate  {
    
    let BorderWidth = CGFloat(1);
    

    @IBOutlet weak var sensorLogo: UIImageView!;
    
    @IBOutlet weak var colorRing: UIView!;
    @IBOutlet weak var borderView: UIView!;
    @IBOutlet weak var placeHolderView: UIView!;
    
    @IBOutlet weak var titleLabel: UILabel!;
    @IBOutlet weak var valueLabel: UILabel!;
    
    @IBOutlet weak var barCharView: JBBarChartView!
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
        
//        let rect : CGRect = view.colorRing.frame;
//        var vista : UIView = UIView(frame: rect);
//        let gradient : CAGradientLayer = CAGradientLayer()
//
//        gradient.frame = vista.bounds
//        
//        let cor1 = UIColor.blackColor().CGColor
//        let cor2 = UIColor.whiteColor().CGColor
//        let arrayColors = [cor1, cor2]
//        
//        gradient.colors = arrayColors
//        view.colorRing.layer.insertSublayer(gradient, atIndex: 0)
        
        view.userInteractionEnabled = true;
        
        return view
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        let newState:JBChartViewState = self.barCharView.state == JBChartViewState.Expanded ? JBChartViewState.Collapsed : JBChartViewState.Expanded;
        
        self.barCharView.setState(newState, animated: true)
    }
    
    override func intrinsicContentSize() -> CGSize {
        var height:CGFloat = 0;
        
        height = height + self.borderView.frame.size.height + (self.colorRing.frame.height/2);
        
        return CGSize(width: 10, height: height);
    }
    
    func initPlot() {
        self.barCharView.delegate = self;
        self.barCharView.dataSource = self;
        self.barCharView.showsVerticalSelection = false;
        
        let x = self.barCharView.frame.minX;
        let XColorring = self.colorRing.frame.minX;
        
        let y = self.barCharView.frame.minY;
        let width = XColorring - x;
        let height = self.barCharView.frame.height;
        //self.barCharView.frame = CGRectMake(x, y, width, height);
        
        self.barCharView.state = JBChartViewState.Collapsed;
    }
    
    func drawChart() {
        if self.barCharView.delegate == nil {
            initPlot();
        }
        
        self.barCharView.reloadData();
        self.barCharView.setState(JBChartViewState.Expanded, animated: true);
    }
    
    //MARK: - JBBarChartView Delegate
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return values[Int(index)];
    }
    
    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        if index%2 == 0 {
            return UIColor.redColor()
        } else {
            return UIColor.greenColor();
        }
    }
    
    //MARK: - JBBarChartView DataSource
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(values.count);
    }
    
    func test () {
        let rect : CGRect = self.colorRing.frame
        var vista : UIView = UIView(frame: rect);
        
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = vista.bounds
        
        let cor1 = UIColor.blackColor().CGColor
        let cor2 = UIColor.whiteColor().CGColor
        let arrayColors = [cor1, cor2]
        
        gradient.colors = arrayColors
        
        self.colorRing.layer.insertSublayer(gradient, atIndex: 0)
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
    
    
}
