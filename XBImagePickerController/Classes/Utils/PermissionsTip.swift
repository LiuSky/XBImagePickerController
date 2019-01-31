//
//  PermissionsTip.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/31.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - 权限提示协议
protocol PermissionsTip {
    
    /// 显示提示
    ///
    /// - Parameter view: <#view description#>
    func showTip(in view: UIView, content: String)
    
    
    /// 隐藏提示
    ///
    /// - Parameter view: <#view description#>
    func hideTip(from view: UIView)
}


// MARK: - <#UIViewController#>
extension PermissionsTip where Self: UIViewController {
    
    /// 显示提示
    func showTip(_ content: String) {
        showTip(in: view, content: content)
    }
    
    /// 隐藏提示
    func hideTip() {
        hideTip(from: view)
    }
    
    
    /// 显示指示器在那个View
    ///
    /// - Parameter view: <#view description#>
    func showTip(in view: UIView, content: String) {
        
        let holderView = XBImagePermissionsTipView()
        holderView.tip = content
        view.addSubview(holderView)
        
        holderView.translatesAutoresizingMaskIntoConstraints = false
        holderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        holderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        holderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        holderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func hideTip(from view: UIView) {
        let holder = view.subviews.first { $0 is XBImagePermissionsTipView }
        holder?.removeFromSuperview()
    }
}

