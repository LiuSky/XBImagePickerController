//
//  ImageGroupTableViewController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/28.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Photos

/// MARK - 相册分组控制器
open class ImageGroupTableViewController: UIViewController, IndicatorDisplay, PermissionsTip {
    
    // 取消按钮
    private lazy var cancelButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItem.Style.plain, target: self, action: #selector(eventForCancel))
    
    /// 列表
    private lazy var tableView: UITableView = {
        let temTableView = UITableView()
        temTableView.backgroundColor = UIColor.white
        temTableView.rowHeight = Configuration.shared.groupConfig.rowHeight
        temTableView.sectionHeaderHeight = 0
        temTableView.sectionFooterHeight = 0
        temTableView.estimatedRowHeight = 0
        temTableView.dataSource = self
        temTableView.delegate = self
        temTableView.register(ImageGroupCell.self, forCellReuseIdentifier: ImageGroupCell.identifier)
        temTableView.tableFooterView = UIView()
        return temTableView
    }()
    
    /// 缩略图的大小
    private lazy var thumbnailSize: CGSize = {
        
        let scale = UIScreen.main.scale
        let width = Configuration.shared.groupConfig.rowHeight * scale
        return CGSize(width: width,
                       height: width)
    }()
    
    
    // 所有相册
    private var allAlbums: [AssetCollection] = []
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "相册"
        navigationItem.rightBarButtonItem = self.cancelButtonItem
        configView()
        configLocation()
        //self.pushGridViewController(nil, animated: false)
    }
    
    /// 配置View
    private func configView() {
        view.addSubview(tableView)
    }
    
    /// 配置位置
    private func configLocation() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        checkPermissionToAccessPhotoLibrary()
    }
    
    deinit {
        debugPrint("释放相册分组列表控制器")
    }
}


// MARK: - private func
extension ImageGroupTableViewController {
    
    /// 验证权限
    private func checkPermissionToAccessPhotoLibrary() {
        
        if allAlbums.count <= 0 {

            AssetManager.standard.checkPermissionToAccessPhotoLibrary {  [weak self] (hasPermission) in
                guard let self = self else { return }
                
                if hasPermission == false {
                    self.showTip(Configuration.shared.guideTip)
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
        AssetManager.standard.fetchAlbums(Configuration.shared.libraryMediaType,
                                            sort: Configuration.shared.sort) { [weak self] (results) in
            guard let self = self else { return }
            self.allAlbums = results
            self.tableView.reloadData()
            self.hideIndicator()
        }
    }
    
    
    /// 取消事件
    @objc private func eventForCancel() {
        
        guard let navigationController = self.navigationController,
              let imagePickerController = navigationController as? ImagePickerController else {
            return
        }
        imagePickerController.eventForCancel()
    }
    
    
    /// 跳转相册列表控制器
    ///
    /// - Parameter assetCollection: <#assetCollection description#>
    private func pushGridViewController(_ assetCollectionModel: AssetCollection?, animated: Bool) {
        
//        let vc = XBImageGridViewController()
//        if let temAssetCollection = assetCollectionModel {
//           vc.navigationItem.title = temAssetCollection.assetCollection.localizedTitle
//           vc.fetchResult = temAssetCollection.assets
//        } else {
//            vc.navigationItem.title = "所有照片"
//        }
//        self.navigationController?.pushViewController(vc, animated: animated)
    }
}


// MARK: - UITableViewDataSource
extension ImageGroupTableViewController: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAlbums.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageGroupCell.identifier) as! ImageGroupCell
        cell.separatorInset = .zero
        cell.accessoryType = .disclosureIndicator
        cell.photoSelImage = Configuration.shared.groupConfig.photoSelImage
        
        let model = self.allAlbums[indexPath.row]
        
        cell.selectedCount = model.selectedCount
        cell.albumName = model.assetCollection.localizedTitle
        cell.albumCount = "(\(model.assets.count))"
        cell.representedAssetIdentifier = model.assets[0].asset.localIdentifier
        AssetManager.standard.requestImage(for: model.assets[0].asset, targetSize: self.thumbnailSize) { (image, _) in
            if cell.representedAssetIdentifier == model.assets[0].asset.localIdentifier {
                cell.thumbnailImage = image
            }
        }
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ImageGroupTableViewController: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.pushGridViewController(self.allAlbums[indexPath.row], animated: true)
    }
}
