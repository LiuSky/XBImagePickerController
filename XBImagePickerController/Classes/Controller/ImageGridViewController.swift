////
////  ImageGridViewController.swift
////  XBImagePickerController
////
////  Created by xiaobin liu on 2019/1/25.
////  Copyright © 2019 Sky. All rights reserved.
////

import UIKit
import Photos
import PhotosUI


/// MARK - ImageGridViewController
public class ImageGridViewController: UIViewController, Animation, IndicatorDisplay, PermissionsTip {
    
    /// 拉取照片结果
    public var fetchResult: PHFetchResult<PHAsset>!
    
    /// 取消按钮
    private lazy var cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItem.Style.done, target: self, action: #selector(eventForCancel))
    
    /// Layout
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let temFlowLayout = UICollectionViewFlowLayout()
        temFlowLayout.itemSize = self.itemSize
        temFlowLayout.minimumLineSpacing = CGFloat(Configuration.shared.gridConfig.minimumLineSpacing)
        temFlowLayout.minimumInteritemSpacing = CGFloat(Configuration.shared.gridConfig.minimumInteritemSpacing)
        temFlowLayout.sectionInset = Configuration.shared.gridConfig.sectionInset
        return temFlowLayout
    }()
    
    /// 集合View
    private lazy var collectionView: UICollectionView = {
        let temCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        temCollectionView.backgroundColor = UIColor.white
        temCollectionView.isPrefetchingEnabled = true
        temCollectionView.register(ImageGridCell.self, forCellWithReuseIdentifier: ImageGridCell.identifier)
        temCollectionView.dataSource = self
        temCollectionView.delegate = self
        return temCollectionView
    }()
    
    /// 预览按钮
    private lazy var previewButtonItem = UIBarButtonItem(title: "预览", style: UIBarButtonItem.Style.plain, target: self, action: #selector(eventForPreview))
    
    /// 选择数量
    private lazy var selectNumButtonItem = UIBarButtonItem(title: "\(AssetManager.standard.selectedPhoto.count)/\(Configuration.shared.gridConfig.selectMaxNumber)", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    
    /// 之前的预热矩形
    private var previousPreheatRect = CGRect.zero
    
    /// 每个ItemSize
    private lazy var itemSize: CGSize = {
        
        let spacing: CGFloat = CGFloat((Configuration.shared.gridConfig.numberOfColumns - 1) * Configuration.shared.gridConfig.minimumInteritemSpacing)
        let width = (UIScreen.main.bounds.size.width - spacing - Configuration.shared.gridConfig.sectionInset.left - Configuration.shared.gridConfig.sectionInset.right) / CGFloat(Configuration.shared.gridConfig.numberOfColumns)
        return CGSize(width: width, height: width)
    }()
    
    
    /// 缩略图的大小
    private lazy var thumbnailSize: CGSize = {
        
        let scale = UIScreen.main.scale
        return CGSize(width: self.itemSize.width * scale, height: self.itemSize.height * scale)
    }()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configData()
        configView()
        configLocation()
    }
    
    /// 配置数据
    private func configData() {
        
        if fetchResult != nil {
            resetCachedAssets()
            PHPhotoLibrary.shared().register(self)
            addToolbarItems()
            navigationController?.setToolbarHidden(false, animated: false)
        }
    }
    
    
    /// 配置View
    private func configView() {
        
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = cancelButton
        view.addSubview(collectionView)
    }
    
    /// 配置位置
    private func configLocation() {
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    /// 添加ToolbarItems
    private func addToolbarItems() {
        
        let leftFix = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        let rightFix = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        let fix = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let fix2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "完成", style: UIBarButtonItem.Style.plain, target: self, action: #selector(eventForDone))
        self.setToolbarItems([leftFix, self.previewButtonItem, fix, self.selectNumButtonItem, fix2, done, rightFix], animated: true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkPermissionToAccessPhotoLibrary()
    }
    
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    
    deinit {
        debugPrint("释放相册列表控制器")
        AssetManager.standard.stopCachingImagesForAllAssets()
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}


// MARK: - private
extension ImageGridViewController {
    
    /// 验证相机权限
    private func checkPermissionToAccessPhotoLibrary() {
        
        if self.fetchResult == nil {
            
            AssetManager.standard.checkPermissionToAccessPhotoLibrary {  [weak self] (hasPermission) in
                guard let self = self else { return }
                if hasPermission == false {
                    self.showTip(Configuration.shared.guideTip)
                } else {
                    self.hideTip()
                    self.showIndicator()
                    self.resetCachedAssets()
                    
//                    XBAssetManager.standard.fetchGridAsset(in: nil,
//                                                           sortAscendingByModificationDate: XBImagePickerConfiguration.shared.sortAscendingByModificationDate,
//                                                           libraryMediaType: XBImagePickerConfiguration.shared.libraryMediaType, block: { (result) in
//                                                            self.fetchResult = result
//                                                            self.addToolbarItems()
//                                                            self.navigationController?.setToolbarHidden(false, animated: true)
//                                                            PHPhotoLibrary.shared().register(self)
//                                                            self.collectionView.reloadData()
//                                                            self.updateCachedAssets()
//                                                            self.hideIndicator()
//                    })
            }
        }
        }
    }
    
    
    /// 取消
    @objc private func eventForCancel() {
        
        guard let navigationController = self.navigationController,
            let imagePickerController = navigationController as? ImagePickerController else {
                return
        }
        imagePickerController.eventForCancel()
    }
    
    
    /// 预览
    @objc private func eventForPreview() {
        //do thing
    }
    
    
    /// 完成事件
    @objc private func eventForDone() {
        
        guard let navigationController = self.navigationController,
            let imagePickerController = navigationController as? ImagePickerController else {
                return
        }
        imagePickerController.eventForDone()
    }
}


// MARK: - UICollectionViewDataSource
extension ImageGridViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.fetchResult != nil {
           return self.fetchResult.count
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGridCell.identifier, for: indexPath) as! ImageGridCell
        cell.delegate = self
        cell.photoSelImage = Configuration.shared.gridConfig.photoSelImage
        cell.photoDefImage = Configuration.shared.gridConfig.photoDefImage
        
        let asset = fetchResult.object(at: indexPath.item)
        
        /// 匹配是否有选中的数量
        var selectedIndex = 0
        for (index, item) in AssetManager.standard.selectedPhoto.enumerated() {
            if item == asset {
                selectedIndex = index + 1
                break
            }
        }
        cell.selectedIndex = selectedIndex
        
        /// 匹配是否是视频
        if asset.mediaType == .video {
            cell.timer = asset.duration.timeSecString
        } else {
            cell.timer = nil
        }
        
        
        /// 资源赋值
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        } else {
            cell.livePhotoBadgeImage = nil
        }
        
        cell.representedAssetIdentifier = asset.localIdentifier
        AssetManager.standard.requestImage(for: asset, targetSize: thumbnailSize, resultHandler: { image, _ in
            /// 在调用此处理程序时，单元格可能已经回收
            /// 只有当单元格的缩略图仍然显示相同的资产时，才设置它
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension ImageGridViewController: UICollectionViewDelegate {
    
}


// MARK: - XBImageGridCellDelegate
extension ImageGridViewController: ImageGridCellDelegate {
    
    public func selectPhoto(_ cell: ImageGridCell, selectImageView: UIImageView, selectPhotoButton: UIButton) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let asset = fetchResult.object(at: indexPath.row)
        if AssetManager.standard.selectedPhoto.contains(asset) {
            
            selectPhotoButton.isSelected = false
            selectImageView.image = cell.photoDefImage
            cell.selectedIndex = 0
            for (index, item) in AssetManager.standard.selectedPhoto.enumerated() {
                if item == asset {
                    AssetManager.standard.selectedPhoto.remove(at: index)
                    break
                }
            }
        } else {
            
            /// 超过最大选择数量
            if Configuration.shared.gridConfig.selectMaxNumber <= AssetManager.standard.selectedPhoto.count {
                navigationController?.view.shake()
                return
            }
            selectPhotoButton.isSelected = true
            selectImageView.image = cell.photoSelImage
            cell.selectedIndex = AssetManager.standard.selectedPhoto.count + 1
            selectImageView.showOscillatoryAnimation()
            AssetManager.standard.selectedPhoto.append(asset)
        }
        
        selectNumButtonItem.title = "\(AssetManager.standard.selectedPhoto.count)/\(Configuration.shared.gridConfig.selectMaxNumber)"
        collectionView.reloadItems(at:
            collectionView.visibleCells.compactMap { collectionView.indexPath(for: $0) }
                                       .filter { $0.row != indexPath.row }
        )
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver
extension ImageGridViewController: PHPhotoLibraryChangeObserver {
    
    /// 照片资源发生变化
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
       
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // 可以在后台队列上发出更改通知。重新分派到主队列在执行更改之前，我们将更新UI
        DispatchQueue.main.sync {
            // 保留新的获取结果.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // 如果我们有增量差分，在集合视图中动画它们.
                collectionView.performBatchUpdates({
                    // 为了使索引有意义，更新必须按照以下顺序进行:
                    //删除、插入、重载、移动
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // 如果增量差异不可用，重新加载集合视图.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}


// MARK: - UIScrollViewDelegate
extension ImageGridViewController {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}


// MARK: - Diff
extension ImageGridViewController {
    
    /// 重置缓存资源
    private func resetCachedAssets() {
        AssetManager.standard.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    
    /// 刷新缓存资源
    private func updateCachedAssets() {
        
        // 仅在视图可见时更新
        guard isViewLoaded && view.window != nil && self.fetchResult != nil else { return }
        
        // 预热视图的高度是可视矩形的两倍.
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // 仅当可见区域与上一个预热区域有显著差异时才更新.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // 计算开始缓存和停止缓存的资产.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // 更新正在缓存的资产
        AssetManager.standard.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill)
        AssetManager.standard.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill)
        
        // 赋值新的预热Rect
        previousPreheatRect = preheatRect
    }
    
    
    /// 矩形之间的差异
    ///
    /// - Parameters:
    ///   - old: 旧的区域
    ///   - new: 新的区域
    /// - Returns: 添加的区域,移除的区域
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}
