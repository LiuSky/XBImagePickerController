//
//  UIView+.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/28.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Foundation


/// MARK - 动画
public protocol Animation {}
extension Animation where Self: UIView {
    
    /// 震动动画
    public func showOscillatoryAnimation() {
        
        UIView.animate(withDuration: 0.15, delay: 0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseInOut], animations: {
            self.layer.setValue(1.15, forKeyPath: "transform.scale")
        }) { (finished) in
            UIView.animate(withDuration: 0.15, delay: 0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseInOut], animations: {
                self.layer.setValue(0.92, forKeyPath: "transform.scale")
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.1, delay: 0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseInOut], animations: {
                    self.layer.setValue(1.0, forKeyPath: "transform.scale")
                }, completion: nil)
            })
        }
    }
    
    
    /// 摇晃
    public func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.08
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5.0, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}


extension UIView: Animation {}
