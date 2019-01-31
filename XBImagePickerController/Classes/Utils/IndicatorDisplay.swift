//
//  IndicatorDisplay.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/31.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - 指标显示协议
protocol IndicatorDisplay {
    
    /// 显示指示器
    ///
    /// - Parameter view: <#view description#>
    func showIndicator(in view: UIView)
    
    
    /// 隐藏指示器
    ///
    /// - Parameter view: <#view description#>
    func hideIndicator(from view: UIView)
}


/// MARK - 指标持有者视图
public class IndicatorHolderView: UIView {}
extension IndicatorDisplay where Self: UIViewController {
    
    /// 显示指示器
    func showIndicator() {
        showIndicator(in: view)
    }
    
    /// 隐藏指示器
    func hideIndicator() {
        hideIndicator(from: view)
    }
    
    
    /// 显示指示器在那个View
    ///
    /// - Parameter view: <#view description#>
    func showIndicator(in view: UIView) {
        
        let holderView = IndicatorHolderView()
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .gray
        holderView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: holderView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: holderView.centerYAnchor).isActive = true
        indicator.startAnimating()
        
        holderView.backgroundColor = .clear
        view.addSubview(holderView)
        
        holderView.translatesAutoresizingMaskIntoConstraints = false
        holderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        holderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        holderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        holderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func hideIndicator(from view: UIView) {
        let holder = view.subviews.first { $0 is IndicatorHolderView }
        holder?.removeFromSuperview()
    }
}

