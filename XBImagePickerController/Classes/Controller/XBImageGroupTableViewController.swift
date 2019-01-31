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
open class XBImageGroupTableViewController: UIViewController, IndicatorDisplay, PermissionsTip {
    
    // 取消按钮
    private lazy var cancelButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItem.Style.plain, target: self, action: #selector(eventForCancel))
    
    /// 列表
    private lazy var tableView: UITableView = {
        let temTableView = UITableView()
        temTableView.backgroundColor = UIColor.white
        temTableView.rowHeight = XBImagePickerConfiguration.shared.groupTableView.rowHeight
        temTableView.sectionHeaderHeight = 0
        temTableView.sectionFooterHeight = 0
        temTableView.estimatedRowHeight = 0
        temTableView.dataSource = self
        temTableView.delegate = self
        temTableView.register(XBImageGroupCell.self, forCellReuseIdentifier: XBImageGroupCell.identifier)
        temTableView.tableFooterView = UIView()
        return temTableView
    }()
    
    /// 缩略图的大小
    private lazy var thumbnailSize: CGSize = {
        
        let scale = UIScreen.main.scale
        return CGSize(width: XBImagePickerConfiguration.shared.groupTableView.rowHeight
            * scale, height: XBImagePickerConfiguration.shared.groupTableView.rowHeight * scale)
    }()
    
    // 所有相册
    private var allAlbums: [PHAssetCollection] = []
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "相册"
        self.navigationItem.rightBarButtonItem = self.cancelButtonItem
        self.configView()
        self.configLocation()
        self.pushGridViewController(nil, animated: false)
    }
    
    /// 配置View
    private func configView() {
        self.view.addSubview(tableView)
    }
    
    /// 配置位置
    private func configLocation() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.checkPermissionToAccessPhotoLibrary()
    }
    
    deinit {
        debugPrint("释放相册分组列表控制器")
    }
}


// MARK: - private func
extension XBImageGroupTableViewController {
    
    /// 验证权限
    private func checkPermissionToAccessPhotoLibrary() {
        
        if self.allAlbums.count <= 0 {
            XBAssetManager.standard.checkPermissionToAccessPhotoLibrary {  [weak self] (hasPermission) in
                guard let self = self else { return }
                if hasPermission == false {
                    self.showTip("请在iPhone的\"设置-隐私-照片\"选项中,\r允许xxxApp访问你的手机相册")
                } else {
                    self.hideTip()
                    self.loadAllAlbums()
                }
            }
        }
    }
    
    /// 加载相册数据
    private func loadAllAlbums() {
        
        self.showIndicator(in: self.view)
        XBAssetManager.standard.fetchAlbums(XBImagePickerConfiguration.shared.libraryMediaType) { [weak self] (results) in
            guard let self = self else { return }
            self.allAlbums = results
            self.tableView.reloadData()
            self.hideIndicator()
        }
    }
    
    
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
    private func pushGridViewController(_ assetCollection: PHAssetCollection?, animated: Bool) {
        
        let vc = XBImageGridViewController()
        if let temAssetCollection = assetCollection {
           vc.assetCollection = temAssetCollection
        }
        self.navigationController?.pushViewController(vc, animated: animated)
    }
}


// MARK: - UITableViewDataSource
extension XBImageGroupTableViewController: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAlbums.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: XBImageGroupCell.identifier) as! XBImageGroupCell
        cell.separatorInset = .zero
        cell.accessoryType = .disclosureIndicator
        cell.photoSelImage = XBImagePickerConfiguration.shared.groupTableView.photoSelImage
        
        let assetCollection = self.allAlbums[indexPath.row]
        let assets = XBAssetManager.standard.fetchAsset(in: assetCollection,
                                                        sortAscendingByModificationDate: XBImagePickerConfiguration.shared.sortAscendingByModificationDate)
        
        /// 选中数量
        var number = 0
        for item in XBAssetManager.standard.selectedPhoto {
            if assets.contains(item) {
                number += 1
            }
        }
        cell.selectedCount = number
        
        
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
extension XBImageGroupTableViewController: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.pushGridViewController(self.allAlbums[indexPath.row], animated: true)
    }
}
