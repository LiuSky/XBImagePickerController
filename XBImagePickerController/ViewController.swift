//
//  ViewController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit

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
        
        var configuration = XBImagePickerConfiguration()
        configuration.libraryMediaType = .all
        
        let na = XBImagePickerController(configuration: configuration)
        na.pickerDelegate = self
        self.present(na, animated: true, completion: nil)
    }
}


// MARK: - XBImageGridViewController
extension ViewController: XBImagePickerControllerDelegate {
    
    func imagePickerDidFinished(_ picker: XBImagePickerController, images: [UIImage]) {
        debugPrint(images)
    }
    
    
    func imagePickerDidCancel(_ picker: XBImagePickerController) {
        debugPrint(picker)
    }
}

