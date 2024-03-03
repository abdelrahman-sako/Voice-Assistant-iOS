//
//  ActionSheet.swift
//  Voice Assistant
//
//  Created by Osama Hasan on 17/01/2024.
//


import UIKit
public class ActionSheet: UIViewController, UIGestureRecognizerDelegate {
    static var Sheets:[ActionSheet] = []
    class func Create<T:UIViewController>(vc:T.Type) ->T{
        let vc = T(nibName: NSStringFromClass(vc.classForCoder()).components(separatedBy: ".").last ?? "", bundle: bundle)
        vc.modalPresentationStyle = .overFullScreen
       // vc.modalTransitionStyle = .crossDissolve
        return vc
    }
    
    public func show(inViewController vc:UIViewController? = nil) {
       //ActionSheet.Sheets.append(self)
        if let vc = vc {
            vc.present(self, animated: false, completion: nil)
        }else {

            UIApplication.shared.topMostViewController?.present(self, animated: false, completion: nil)
        }
       
    }

    func showWithNavigationController(){
        let nav = UINavigationController(rootViewController: self)
        nav.modalPresentationStyle = .overFullScreen
        UIApplication.shared.topMostViewController?.present(nav, animated: false, completion: nil)
    }
    
    private var containerView:UIView?
    private var backgroundView:UIView!
    private var animationSpeed:CGFloat = 0.4
    private var parentSheet:ActionSheet? {
        if ActionSheet.Sheets.count > 1 {
            return ActionSheet.Sheets[0]
        }
        return nil
    }
    private var parentSheetOriginY:CGFloat = 0
    private var isParentSheetRequireTransitionAnimation:Bool = false
    private var parentSheetDisplacementOffset:CGFloat = 100.0
    private var parentSheetScale:CGFloat = 0.96 // value from 0 to 1
    var isSheetLocked:Bool = false
    var animatedViews:[UIView] = []
    
    private var maxAlpha:CGFloat{
        return  ActionSheet.Sheets.count > 1 ? 0.3 : 0.4
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0 // to remove the glitch since  present animation = false
        backgroundView = addBackgroundView()
        addDismissButton()
    }
  
    public override func viewDidAppear(_ animated: Bool) {
        view.alpha = 1
        showWithAnimation()
        addSwipGesture()
    }
    
    func addBackgroundView()->UIView {
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = .black
        backgroundView.alpha = maxAlpha
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(backgroundView, at: 0)
        return backgroundView
    }
    
      var panGestureRecognizer: UIPanGestureRecognizer?
      var originalPosition: CGPoint?
      var originalPositionForView: CGPoint?
      var maxPosition: CGPoint?
      var currentPositionTouched: CGPoint?
      
    func addSwipGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
    }
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer)  {
        guard !isSheetLocked else {
            return
        }
        let translation = panGesture.translation(in: view)
        
        if panGesture.state == .began {
            originalPosition = containerView!.frame.origin
            originalPositionForView = animatedViews.first!.frame.origin
            maxPosition = CGPoint(x: 0, y:  self.view.frame.size.height -  (containerView!.frame.size.height)/2)
            currentPositionTouched = panGesture.location(in: view)
            self.view.endEditing(true)
        } else if panGesture.state == .changed {
            guard  let orginalY = originalPosition?.y else {
                return
            }
            guard  let orginalYForView = originalPositionForView?.y else {
                return
            }
           
            if orginalY < orginalY  + translation.y {
                containerView!.frame.origin.y = orginalY  + translation.y
                let alpha = (self.view.frame.size.height -  containerView!.frame.origin.y) / (self.view.frame.size.height - orginalY)
                self.backgroundView.alpha = alpha*maxAlpha
               
                
                self.animatedViews.forEach({$0.frame.origin.y = orginalYForView  + translation.y})

                if let parentSheet = parentSheet {
                    var  dampingRation = 1.000 - ( (translation.y / 250) * 0.200 )
                    dampingRation = dampingRation > 0.800 ?  dampingRation : 0.800
                   
                    let scaleDifference = 1 - parentSheetScale
                    var scaleRatio = (translation.y / (abs(orginalY - parentSheetOriginY ) +  parentSheetDisplacementOffset)) * scaleDifference
                    scaleRatio  = scaleRatio > scaleDifference ? scaleDifference : scaleRatio
                    let yTranslate = abs(orginalY - parentSheetOriginY) + parentSheetDisplacementOffset - translation.y*dampingRation
                    if yTranslate > 0 && isParentSheetRequireTransitionAnimation {
                        parentSheet.containerView?.transform = CGAffineTransform(scaleX: parentSheetScale + scaleRatio, y: parentSheetScale + scaleRatio).translatedBy(x: 0, y: -yTranslate)
                    }else if !isParentSheetRequireTransitionAnimation{
                        parentSheet.containerView?.transform = CGAffineTransform(scaleX: parentSheetScale + scaleRatio, y: parentSheetScale + scaleRatio)
                    }else{
                        parentSheet.containerView?.transform = CGAffineTransform.identity
                    }
                }
                
            }else {
                containerView!.frame.origin.y =  orginalY
                self.animatedViews.forEach({$0.frame.origin.y = orginalYForView })

                if let parentSheet = parentSheet, isParentSheetRequireTransitionAnimation  {
                    let yTranslate = -((abs(orginalY - parentSheetOriginY) +  parentSheetDisplacementOffset))
                    parentSheet.containerView?.transform = CGAffineTransform(scaleX: parentSheetScale, y: parentSheetScale).translatedBy(x: 0, y:yTranslate)
                }
                self.backgroundView.alpha = maxAlpha
               // self.animatedViews.forEach({$0.alpha = 1})
            }
        } else if panGesture.state == .ended {
            guard let maxPosition = maxPosition else {
                return
            }
            let velocity = panGesture.velocity(in: view)
            
            if velocity.y >= 1500  ||  containerView!.frame.origin.y > maxPosition.y {
                UIView.animate(withDuration: 0.2
                               , animations: {
                    self.containerView!.frame.origin.y = self.view.frame.size.height
                    if let parentSheet = self.parentSheet {
                        parentSheet.containerView?.transform = CGAffineTransform.identity
                    }
                    self.backgroundView.alpha = 0
                    //self.animatedViews.forEach({$0.alpha = 0})
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.generalDismiss()
                    }
                })
            }else {
                guard let orginalY = originalPosition?.y else {
                    return
                }
                guard  let orginalYForView = originalPositionForView?.y else {
                    return
                }
                UIView.animate(withDuration: 0.2, animations: {
                    self.containerView!.frame.origin.y = orginalY
                    self.animatedViews.forEach({$0.frame.origin.y = orginalYForView })

                    if let parentSheet = self.parentSheet {
                        let scale = self.parentSheetScale
                        if self.isParentSheetRequireTransitionAnimation {
                            parentSheet.containerView?.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: -(abs(orginalY - (self.parentSheetOriginY )) +  self.parentSheetDisplacementOffset))
                        }else {
                            parentSheet.containerView?.transform = CGAffineTransform(scaleX: scale, y: scale)
                        }
                    }
                    self.backgroundView.alpha = self.maxAlpha
                })
            }
        }
        
    }
    
    

   
    func actionSheetSetup(animatedView view:UIView,
                          animationSpeed:CGFloat = 0.4,
                          dismissButton:UIButton? = nil){
        containerView = view
        self.animationSpeed = animationSpeed
        dismissButton?.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
    }
    
    func actionSheetSetup(animatedView view:UIView,
                          animationSpeed:CGFloat = 0.4,
                          withViews:[UIView],
                          dismissButton:UIButton? = nil){
        containerView = view
        self.animationSpeed = animationSpeed
        self.animatedViews = withViews
        dismissButton?.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
    }
    func  addDismissButton(){
        let button = UIButton(frame: UIScreen.main.bounds)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        self.view.insertSubview(button, aboveSubview: backgroundView)
    }
    
    func sheetWillDismiss()  {
        // override this method
    }
   
    @objc private func dismissAction(){
        guard !isSheetLocked else {return}
        hideWithAnimation { [weak self] _ in
            self?.generalDismiss()
        }
    }
    
    // calling this with completion will led to ignore calling sheetWillDismiss
    public func dismissWithCompletion(completionHandler:(()->Void)? = nil){
        hideWithAnimation { [weak self]  _ in
            //self.dismiss(animated: false,completion: completionHandler)
            self?.generalDismiss(completionHandler: completionHandler)
        }
    }
    
    func generalDismiss(completionHandler:(()->Void)? = nil) {
        ActionSheet.Sheets.removeAll(where: {$0 == self})
        if completionHandler == nil {
            sheetWillDismiss()
        }
        self.dismiss(animated: false,completion: completionHandler)
    }
    
   
    private func showWithAnimation(){
        backgroundView.alpha = 0
        let childSheetOriginY =  containerView?.frame.origin.y ?? 0
        containerView?.frame.origin.y = UIScreen.main.bounds.height
        UIView.animate(withDuration: animationSpeed) { [weak self] in
            self?.containerView?.frame.origin.y = childSheetOriginY
            self?.backgroundView.alpha = self?.maxAlpha  ?? 1
            self?.animatedViews.forEach({$0.alpha = 1})

            if let parentSheet = self?.parentSheet {
                let parentSheetOriginY = parentSheet.containerView?.frame.minY ?? 0
                self?.parentSheetOriginY = parentSheetOriginY
                self?.isParentSheetRequireTransitionAnimation = parentSheetOriginY > childSheetOriginY - (self?.parentSheetDisplacementOffset ?? 0)
                let scale = self?.parentSheetScale ?? 0.96
                if self?.isParentSheetRequireTransitionAnimation ?? false {
                    parentSheet.containerView?.transform = CGAffineTransform(scaleX: scale, y: scale)
                        .translatedBy(x: 0, y: -(abs(childSheetOriginY - parentSheetOriginY) +  (self?.parentSheetDisplacementOffset ?? 0) ))
                }else {
                    parentSheet.containerView?.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
        }
    }
    private func hideWithAnimation(completion:@escaping (Bool) -> Void){
        backgroundView.alpha = maxAlpha
        UIView.animate(withDuration: animationSpeed, animations: { [weak self] in
            self?.containerView?.frame.origin.y = UIScreen.main.bounds.height
            
            if let parentSheet = self?.parentSheet {
                parentSheet.containerView?.transform = CGAffineTransform.identity
            }
            self?.backgroundView.alpha = 0
            self?.animatedViews.forEach({$0.alpha = 0})
        }, completion: completion)
    }
}
