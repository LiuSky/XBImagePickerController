//
//  XBImagePickerController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/28.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - 照片选择控制器
open class XBImagePickerController: UINavigationController {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barStyle = .black
        self.navigationBar.tintColor = UIColor.white
        self.toolbar.barStyle = .black
        self.toolbar.tintColor = UIColor.white
        self.navigationItem.title = "相册"
    }
    
    
    init() {
        let vc = XBImageGroupTableViewController()
        super.init(rootViewController: vc)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - event private
extension XBImagePickerController {
    
    @objc public func eventForCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
