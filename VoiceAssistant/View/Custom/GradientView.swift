//
//  GradientView.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 15/01/2024.
//

import UIKit


class GradientView: UIView
{

    func setGradient(_ grad: GradientSpecs) -> Void
    {
        self.colors = grad.colors
        self.locations = grad.locations
        self.start = grad.start
        self.end = grad.end
    }

    var colors: [UIColor] = [UIColor.black, UIColor.white]
    var locations: [CGFloat] = [0.0, 1.0]

    var start = CGPoint(x: 0, y: 0)
    var end = CGPoint(x: 1, y: 0)

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.isOpaque = false
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }

    override func draw(_ rect: CGRect)
    {

        let context = UIGraphicsGetCurrentContext()!
        let colors = self.colors.map
        { (color) -> CGColor in
            return color.cgColor
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = self.locations

        let gradient = CGGradient(colorsSpace: colorSpace,
                colors: colors as CFArray,
                locations: colorLocations)!

        let startPoint = CGPoint(x: self.start.x * bounds.width, y: self.start.y * bounds.height)
        let endPoint = CGPoint(x: self.end.x * bounds.width, y: self.end.y * bounds.height)

        context.clear(rect)
        context.drawLinearGradient(gradient,
                start: startPoint,
                end: endPoint,
                options: [])
    }
}

class DynamicGradientView: UIView {
    var colors:[CGColor] = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
    var locations:[NSNumber]?
    var startPoint:CGPoint = CGPoint(x: 0, y: 0)
    var endPoint:CGPoint = CGPoint(x: 1, y: 0)
    init(colors:[CGColor] ,frame: CGRect , locations:[NSNumber]? = nil ,startPoint:CGPoint =  CGPoint(x: 0, y: 0) , endPoint:CGPoint = CGPoint(x: 1, y: 0)) {
        super.init(frame: frame)
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.locations = locations
        setupView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }

        theLayer.colors = colors
        theLayer.locations = locations
        theLayer.startPoint  = startPoint
        theLayer.endPoint  = endPoint
        theLayer.frame = self.bounds
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}


