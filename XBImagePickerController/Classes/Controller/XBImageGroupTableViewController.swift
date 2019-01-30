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
    
    // 取消按钮
    private lazy var cancelButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItem.Style.plain, target: self, action: #selector(eventForCancel))
    
    /// 缩略图的大小
    private lazy var thumbnailSize: CGSize = {
        
        let scale = UIScreen.main.scale
        return CGSize(width: XBImagePickerConfiguration.shared.groupTableView.rowHeight
            * scale, height: XBImagePickerConfiguration.shared.groupTableView.rowHeight * scale)
    }()
    
    // 所有相册
    private lazy var allAlbums: [PHAssetCollection] = {
        var temAll = XBAssetManager.standard.allAlbums()
        switch XBImagePickerConfiguration.shared.libraryMediaType {
        case .all:
            return temAll
        case .image:
            return temAll.filter { $0.assetCollectionSubtype != .smartAlbumVideos }
        case .video:
            return temAll.filter { $0.assetCollectionSubtype == .smartAlbumVideos }
        }
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "相册"
        self.navigationItem.rightBarButtonItem = self.cancelButtonItem
        self.tableView.rowHeight = XBImagePickerConfiguration.shared.groupTableView.rowHeight
        self.tableView.sectionHeaderHeight = 0
        self.tableView.sectionFooterHeight = 0
        self.tableView.estimatedRowHeight = 0
        self.tableView.register(XBImageGroupCell.self, forCellReuseIdentifier: XBImageGroupCell.identifier)
        self.tableView.tableFooterView = UIView()
        self.pushGridViewController(self.allAlbums[0], animated: false)
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.tableView.reloadData()
    }
    
    deinit {
        debugPrint("释放相册分组列表控制器")
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
    
    
    /// 跳转相册列表控制器
    ///
    /// - Parameter assetCollection: <#assetCollection description#>
    private func pushGridViewController(_ assetCollection: PHAssetCollection, animated: Bool) {
        
        let vc = XBImageGridViewController(assetCollection: assetCollection)
        self.navigationController?.pushViewController(vc, animated: animated)
    }
}

// MARK: - private func
extension XBImageGroupTableViewController {
    
    /// 拉取相册资源
    ///
    /// - Parameter assetCollection: PHAssetCollection
    /// - Returns: return value description
    private func fetchAsset(in assetCollection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: XBImagePickerConfiguration.shared.sortAscendingByModificationDate)]
        return XBAssetManager.standard.fetchAssets(in: assetCollection, options: allPhotosOptions)
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
        cell.photoSelImage = XBImagePickerConfiguration.shared.groupTableView.photoSelImage
        
        let assetCollection = self.allAlbums[indexPath.row]
        let assets = self.fetchAsset(in: assetCollection)
        
        var number = 0
        for item in XBAssetManager.standard.selectedPhoto {
            if assets.contains(item) {
                number += 1
            }
        }
    
        cell.selectedIndex = number
        cell.albumName = assetCollection.localizedTitle
        cell.albumCount = "(\(assetCollection.photosCount))"
        cell.representedAssetIdentifier = assets[0].localIdentifier
        XBAssetManager.standard.requestImage(for: assets[0], targetSize: self.thumbnailSize) { (image, _) in
            if cell.representedAssetIdentifier == assets[0].localIdentifier {
                cell.thumbnailImage = image
            }
        }
        return cell
    }
}


// MARK: - UITableViewDelegate
extension XBImageGroupTableViewController {
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.pushGridViewController(self.allAlbums[indexPath.row], animated: true)
    }
}
