//
//  XBImageGroupTableViewController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/28.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Photos

/// MARK - 相册分组控制器
open class XBImageGroupTableViewController: UITableViewController {

    /// 对照片排序，按修改时间升序，默认是NO。如果设置为No,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
    public var sortAscendingByModificationDate: Bool = false
    
    // 取消按钮
    private lazy var cancelButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItem.Style.plain, target: self, action: #selector(eventForCancel))
    
    /// 行高默认60高度
    private lazy var rowHeight: CGFloat = 70
    
    /// 缩略图的大小
    private lazy var thumbnailSize: CGSize = {
        
        let scale = UIScreen.main.scale
        return CGSize(width: self.rowHeight * scale, height: self.rowHeight * scale)
    }()
    
    // 所有相册
    private lazy var allAlbums: [PHAssetCollection] = {
        let temAll = XBAssetManager.standard.allAlbums()
        return temAll
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "相册"
        self.navigationItem.rightBarButtonItem = self.cancelButtonItem
        self.tableView.rowHeight = self.rowHeight
        self.tableView.register(XBImageGroupCell.self, forCellReuseIdentifier: XBImageGroupCell.identifier)
        self.tableView.tableFooterView = UIView()
    }
}


// MARK: - event private
extension XBImageGroupTableViewController {
    
    /// 取消事件
    @objc private func eventForCancel() {
        
        guard let navigationController = self.navigationController,
              let imagePickerController = navigationController as? XBImagePickerController else {
            return
        }
        imagePickerController.eventForCancel()
    }
}


// MARK: - UITableViewDataSource
extension XBImageGroupTableViewController {
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAlbums.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: XBImageGroupCell.identifier) as! XBImageGroupCell
        cell.separatorInset = .zero
        cell.accessoryType = .disclosureIndicator
        
        let assetCollection = self.allAlbums[indexPath.row]
        let asset = self.fetchAsset(in: assetCollection)
        
        cell.albumName = assetCollection.localizedTitle
        cell.albumCount = "(\(assetCollection.photosCount))"
        cell.representedAssetIdentifier = asset.localIdentifier
        XBAssetManager.standard.requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
            /// 在调用此处理程序时，单元格可能已经回收
            /// 只有当单元格的缩略图仍然显示相同的资产时，才设置它
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        }
        return cell
    }
}


// MARK: - private func
extension XBImageGroupTableViewController {
    
    /// 拉去相册资源第一项
    ///
    /// - Parameter assetCollection: PHAssetCollection
    /// - Returns: <#return value description#>
    private func fetchAsset(in assetCollection: PHAssetCollection) -> PHAsset {
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)]
        return XBAssetManager.standard.fetchAssets(in: assetCollection, options: allPhotosOptions).object(at: 0)
    }
}
