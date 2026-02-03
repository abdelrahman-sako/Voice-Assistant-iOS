//
//  UIViewControllerExtension.swift
//  VoiceAssistant
//
//  Created by Yazan Kareem on 27/01/2026.
//

import UIKit

extension UIViewController {
    
    /// Show the controller with a fade-in animation
    func presentAnimated(over parentVC: UIViewController, viewAlpha: CGFloat, duration: TimeInterval = 0.25, completion: (() -> Void)? = nil) {
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        
        // Optional: make background transparent
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        parentVC.present(self, animated: false) {
            UIView.animate(withDuration: duration) {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(viewAlpha)
            } completion: { _ in
                completion?()
            }
        }
    }
    
    /// Enable tap-to-dismiss with fade-out animation
    func enableTapToDismissAnimated(duration: TimeInterval = 0.25) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelfAnimated(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &AssociatedKeys.dismissAnimationDuration, duration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func dismissSelfAnimated(_ gesture: UITapGestureRecognizer) {
        let duration = objc_getAssociatedObject(self, &AssociatedKeys.dismissAnimationDuration) as? TimeInterval ?? 0.25
        UIView.animate(withDuration: duration, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    /// Dismiss with fade-out and completion
    func dismissAnimated(duration: TimeInterval = 0.25, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
}

// MARK: - AssociatedKeys for objc_setAssociatedObject
private struct AssociatedKeys {
    static var dismissAnimationDuration = "dismissAnimationDuration"
}
