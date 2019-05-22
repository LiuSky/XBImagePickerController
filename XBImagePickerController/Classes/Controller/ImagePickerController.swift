//
//  ImagePickerController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/28.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Photos


/// MARK - ImagePickerControllerDelegate
public protocol ImagePickerControllerDelegate: NSObjectProtocol {
    

    /// 选择完成
    ///
    /// - Parameters:
    ///   - picker: 照片选择控制器
    ///   - images: 图片数组
    func imagePickerDidFinished(_ picker: ImagePickerController, images: [UIImage])
    
    
    
    /// 取消选择
    ///
    /// - Parameter picker: 照片选择控制器
    func imagePickerDidCancel(_ picker: ImagePickerController)
}


/// MARK - 照片选择控制器
open class ImagePickerController: UINavigationController {
    
    /// 回调
    public weak var pickerDelegate: ImagePickerControllerDelegate?
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barStyle = .black
        navigationBar.tintColor = UIColor.white
        toolbar.barStyle = .black
        toolbar.tintColor = UIColor.white
        navigationItem.title = "相册"
    }
    
    
    public convenience init() {
        self.init(configuration: Configuration.shared)
    }
    
    public required init(configuration: Configuration) {
        Configuration.shared = configuration
        let vc = ImageGroupTableViewController()
        super.init(rootViewController: vc)
    }
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        AssetManager.standard.selectedPhoto.removeAll()
        debugPrint("释放照片选择控制器")
    }
}


// MARK: - event private
extension ImagePickerController {
    
    /// 取消
    public func eventForCancel() {
        self.pickerDelegate?.imagePickerDidCancel(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 完成
    public func eventForDone() {
        
        debugPrint("加载中...")
        var result: [UIImage] = []
        for item in AssetManager.standard.selectedPhoto {
            AssetManager.standard.requestImage(for: item,
                                                 targetSize: CGSize(width: item.pixelWidth, height: item.pixelHeight)) { (image, info) in
                                                    
                 result.append(image!)
                 if result.count == AssetManager.standard.selectedPhoto.count {
                    debugPrint("加载完成...")
                    self.pickerDelegate?.imagePickerDidFinished(self, images: result)
                    self.dismiss(animated: true, completion: nil)
                 }
            }
        }
    }
}
