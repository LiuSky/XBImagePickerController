//
//  XBImagePickerController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/28.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Photos


/// MARK - XBImagePickerControllerDelegate
public protocol XBImagePickerControllerDelegate: NSObjectProtocol {
    
     /// 图片选择完成
     ///
     /// - Parameter picker: <#picker description#>
     func imagePickerDidFinished(_ picker: XBImagePickerController, images: [UIImage])
    
    
     /// 图片选择取消
     ///
     /// - Parameter picker: <#picker description#>
    func imagePickerDidCancel(_ picker: XBImagePickerController)
}


/// MARK - 照片选择控制器
open class XBImagePickerController: UINavigationController {
    
    /// 回调
    public weak var pickerDelegate: XBImagePickerControllerDelegate?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barStyle = .black
        self.navigationBar.tintColor = UIColor.white
        self.toolbar.barStyle = .black
        self.toolbar.tintColor = UIColor.white
        self.navigationItem.title = "相册"
    }
    
    
    public convenience init() {
        self.init(configuration: XBImagePickerConfiguration.shared)
    }
    
    public required init(configuration: XBImagePickerConfiguration) {
        XBImagePickerConfiguration.shared = configuration
        let vc = XBImageGroupTableViewController()
        super.init(rootViewController: vc)
    }
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        XBAssetManager.standard.selectedPhoto.removeAll()
        debugPrint("释放照片选择控制器")
    }
}


// MARK: - event private
extension XBImagePickerController {
    
    /// 取消
    public func eventForCancel() {
        self.pickerDelegate?.imagePickerDidCancel(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 完成
    public func eventForDone() {
        
        debugPrint("加载中...")
        var result: [UIImage] = []
        for item in XBAssetManager.standard.selectedPhoto {
            XBAssetManager.standard.requestImage(for: item,
                                                 targetSize: CGSize(width: item.pixelWidth, height: item.pixelHeight)) { (image, info) in
                                                    
                 result.append(image!)
                 if result.count == XBAssetManager.standard.selectedPhoto.count {
                    debugPrint("加载完成...")
                    self.pickerDelegate?.imagePickerDidFinished(self, images: result)
                    self.dismiss(animated: true, completion: nil)
                 }
            }
        }
    }
}
