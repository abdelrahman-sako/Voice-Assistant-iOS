//
//  CircularGradientLoadingIndicator.swift
//  NVActivityIndicatorViewExample
//
//  Created by Abdulrahman on 12/19/19.
//  Copyright © 2019 Imagine Technologies. All rights reserved.
//

import UIKit

public class CircularGradientLoadingIndicator: UIView {
    private var width:CGFloat = 80
    lazy var loaderView:UIView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: width)))
    var containerView:UIView?
    static let shared = CircularGradientLoadingIndicator()
    let loaderLabel = UILabel()
    public var LoadingText:String = "تحميل..." {
        didSet{
            loaderLabel.text = LoadingText
        }
    }
    var storkeWidth:CGFloat = 5 //{
//        didSet{
//            setNeedsDisplay()
//        }
//    }
    
    var storkeColor:UIColor = UIColor.gray //{
//        didSet{
//            setNeedsDisplay()
//        }
//    }
    
    private static var isShown = false
    
    private init(){
       
        let topSpace:CGFloat = 10
        let sideSpaces:CGFloat = 50
        let origin = CGPoint(x: UIScreen.main.bounds.size.width/2 - (width + sideSpaces)/2, y: UIScreen.main.bounds.size.height/2 -  (width + topSpace + 45)/2)
        
        super.init(frame: UIScreen.main.bounds)
        
         if CircularGradientLoadingIndicator.isShown {return}
        
        
        
        containerView = UIView(frame: CGRect(origin: origin, size: CGSize(width: width + sideSpaces, height: width + topSpace + 45)))
        self.addSubview(containerView!)
        containerView?.backgroundColor = .clear
        containerView?.addSubview(loaderView)
        
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.widthAnchor.constraint(equalToConstant: width).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: width).isActive = true
        loaderView.topAnchor.constraint(equalTo: (containerView?.topAnchor)!, constant: topSpace).isActive = true
        loaderView.centerXAnchor.constraint(equalTo: (containerView?.centerXAnchor)!, constant: 0).isActive = true
        
        containerView?.layer.cornerRadius = 10
        containerView?.layer.masksToBounds = true
        addLoaderLabel()
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        addBlurEffect()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    public override func draw(_ rect: CGRect) {
        for layer in self.loaderView.layer.sublayers ?? [] {
            layer.removeFromSuperlayer()
        }
        let shapeLayer = CAGradientLayer()
        shapeLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        shapeLayer.endPoint = CGPoint(x: 0.5, y: 0.8)
        shapeLayer.colors =  [storkeColor.withAlphaComponent(0.0).cgColor , storkeColor.withAlphaComponent(0.5).cgColor ,storkeColor.cgColor]
        
        shapeLayer.locations = [0.25,0.5,0.7]
        shapeLayer.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        
        
        let maskLayer =  CAShapeLayer()
        let path1: UIBezierPath = UIBezierPath()
        
        path1.addArc(withCenter: CGPoint(x: width/2, y: width/2), radius: width/2 - 5, startAngle: 1.5*CGFloat.pi, endAngle: -0.5*CGFloat.pi, clockwise: false)
        maskLayer.path = path1.cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.red.cgColor
        maskLayer.lineWidth = storkeWidth
        maskLayer.frame = CGRect(x: 0, y: 0, width: width, height: width)
        maskLayer.strokeStart = 0.25
        maskLayer.strokeEnd = 1.0
        shapeLayer.mask = maskLayer
        startAnimation(layer:shapeLayer)
        self.loaderView.layer.addSublayer(shapeLayer)
    }
    
    func startAnimation(layer:CALayer  )  {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [0, 2*CGFloat.pi]
        animation.duration = 2
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "rotate")
    }
    
//    func storkAnimation(layer:CALayer ,  delay:Double  )  {
//        let animation = CAKeyframeAnimation(keyPath: "strokeStart")
//        animation.values = [0.25, 1]
//        animation.duration = 1
//        animation.repeatCount = HUGE
//        animation.isRemovedOnCompletion = false
//        animation.beginTime = delay
//        //animation.autoreverses = true
//        layer.add(animation, forKey: "strokeStart")
//    }
    
   static func show()  {
        if let rootVC = UIApplication.shared.keyWindow//?.rootViewController
        {
         
            
            if !shared.isDescendant(of: rootVC){
                    CircularGradientLoadingIndicator.isShown = true
                
                shared.LoadingText = AssistantConfig.loaderTheme.loaderText
                
                    rootVC.addSubview(shared)
                shared.containerView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    UIView.animate(withDuration: 0.1) {
                        shared.containerView?.transform = CGAffineTransform.identity
                    }
                
            }
            
            
        }else{
            print("loader error")
        }
    }
    
   static func dismiss()  {
        shared.removeFromSuperview()
        isShown = false
    }
    
    func addLoaderLabel()  {
        loaderLabel.text = LoadingText
        loaderLabel.font = applyBotFont(size: 12)
        loaderLabel.textColor = .black
        loaderLabel.sizeToFit()
        containerView?.addSubview(loaderLabel)
        loaderLabel.translatesAutoresizingMaskIntoConstraints = false
        loaderLabel.topAnchor.constraint(equalTo: self.loaderView.bottomAnchor, constant: 10).isActive = true
        loaderLabel.centerXAnchor.constraint(equalTo: (containerView?.centerXAnchor)!, constant: 0).isActive = true
    }
    
    func addBlurEffect()  {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.alpha = 0.9
        containerView?.insertSubview(blurEffectView, at: 0)
        
    }
    
    
    
}
