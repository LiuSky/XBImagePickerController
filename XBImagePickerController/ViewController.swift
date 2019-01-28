//
//  ViewController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    public lazy var button: UIButton = {
        let temButton = UIButton(type: .custom)
        temButton.backgroundColor = UIColor.red
        temButton.setTitle("跳转", for: .normal)
        temButton.setTitleColor(UIColor.white, for: .normal)
        temButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        temButton.center = self.view.center
        temButton.addTarget(self, action: #selector(push), for: .touchUpInside)
        return temButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
    }
    
    
    /// 跳转
    @objc private func push() {
        
        let vc = XBGridViewController()
        vc.sortAscendingByModificationDate = false
        vc.allowPickingMediaType = .all
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
