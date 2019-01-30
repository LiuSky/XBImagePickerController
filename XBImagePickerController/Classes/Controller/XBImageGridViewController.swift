//
//  XBImageGridViewController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Photos
import PhotosUI


/// MARK - XBImageGridViewController
public class XBImageGridViewController: UICollectionViewController, Animation {
    
//    /// 选择最大数量
//    public var selectMaxNumber = 9 {
//        didSet {
//            self.selectNumButtonItem.title = "\(0)/\(selectMaxNumber)"
//        }
//    }
    
    /// 拉取照片结果
    private lazy var fetchResult: PHFetchResult<PHAsset> = {
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: XBImagePickerConfiguration.shared.sortAscendingByModificationDate)]
        
        switch XBImagePickerConfiguration.shared.libraryMediaType {
        case .all:
            return PHAsset.fetchAssets(in: self.assetCollection, options: allPhotosOptions)
        case .image:
            allPhotosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            return PHAsset.fetchAssets(in: self.assetCollection, options: allPhotosOptions)
        case .video:
            allPhotosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            return PHAsset.fetchAssets(in: self.assetCollection, options: allPhotosOptions)
        }
    }()
    
    /// 资产集合
    private var assetCollection: PHAssetCollection
    
    /// 取消按钮
    private lazy var cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItem.Style.done, target: self, action: #selector(eventForCancel))
    
    /// 选择数量
    private lazy var selectNumButtonItem = UIBarButtonItem(title: "\(XBAssetManager.standard.selectedPhoto.count)/\(XBImagePickerConfiguration.shared.gridView.selectMaxNumber)", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    
    /// 预览按钮
    private lazy var previewButtonItem = UIBarButtonItem(title: "预览", style: UIBarButtonItem.Style.plain, target: self, action: #selector(eventForPreview))
    
    /// 之前的预热矩形
    private var previousPreheatRect = CGRect.zero
    
    /// 每个ItemSize
    private lazy var itemSize: CGSize = {
        
        let spacing: CGFloat = CGFloat((XBImagePickerConfiguration.shared.gridView.numberOfColumns - 1) * XBImagePickerConfiguration.shared.gridView.minimumInteritemSpacing)
        let width = (UIScreen.main.bounds.size.width - spacing - XBImagePickerConfiguration.shared.gridView.sectionInset.left - XBImagePickerConfiguration.shared.gridView.sectionInset.right) / CGFloat(XBImagePickerConfiguration.shared.gridView.numberOfColumns)
        return CGSize(width: width, height: width)
    }()
    
    /// 缩略图的大小
    private lazy var thumbnailSize: CGSize = {
        
        let scale = UIScreen.main.scale
        return CGSize(width: self.itemSize.width * scale, height: self.itemSize.height * scale)
    }()
    
    /// Layout
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let temFlowLayout = UICollectionViewFlowLayout()
        temFlowLayout.itemSize = self.itemSize
        temFlowLayout.minimumLineSpacing = CGFloat(XBImagePickerConfiguration.shared.gridView.minimumLineSpacing)
        temFlowLayout.minimumInteritemSpacing = CGFloat(XBImagePickerConfiguration.shared.gridView.minimumInteritemSpacing)
        temFlowLayout.sectionInset = XBImagePickerConfiguration.shared.gridView.sectionInset
        return temFlowLayout
    }()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.assetCollection.localizedTitle
        self.navigationItem.rightBarButtonItem = self.cancelButton
        self.collectionView.isPrefetchingEnabled = true
        self.collectionView.collectionViewLayout = self.flowLayout
        
        self.resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        self.view.backgroundColor = UIColor.white
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(XBImageGridCell.self, forCellWithReuseIdentifier: XBImageGridCell.identifier)
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.addToolbarItems()
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
    
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    
    init(assetCollection: PHAssetCollection) {
        self.assetCollection = assetCollection
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("释放相册列表控制器")
        XBAssetManager.standard.stopCachingImagesForAllAssets()
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}


// MARK: - private event
extension XBImageGridViewController {
    
    /// 取消
    @objc private func eventForCancel() {
        
        guard let navigationController = self.navigationController,
            let imagePickerController = navigationController as? XBImagePickerController else {
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
            let imagePickerController = navigationController as? XBImagePickerController else {
                return
        }
        imagePickerController.eventForDone()
    }
}


// MARK: - UICollectionViewDataSource
extension XBImageGridViewController {

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.fetchResult.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XBImageGridCell.identifier, for: indexPath) as! XBImageGridCell
        cell.delegate = self
        cell.photoSelImage = #imageLiteral(resourceName: "photoSelImage")
        cell.photoDefImage = #imageLiteral(resourceName: "photoDefImage")
        
        let asset = fetchResult.object(at: indexPath.item)
        
        /// 匹配是否有选中的数量
        var selectedIndex = 0
        for (index, item) in XBAssetManager.standard.selectedPhoto.enumerated() {
            if item == asset {
                selectedIndex = index + 1
                break
            }
        }
        cell.selectedIndex = selectedIndex
        
        
        /// 资源赋值
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        } else {
            cell.livePhotoBadgeImage = nil
        }
        
        cell.representedAssetIdentifier = asset.localIdentifier
        XBAssetManager.standard.requestImage(for: asset, targetSize: thumbnailSize, resultHandler: { image, _ in
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
extension XBImageGridViewController {
    
}


// MARK: - XBImageGridCellDelegate
extension XBImageGridViewController: XBImageGridCellDelegate {
    
    public func selectPhoto(_ cell: XBImageGridCell, selectImageView: UIImageView, selectPhotoButton: UIButton) {
        
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return
        }
        
        let asset = self.fetchResult.object(at: indexPath.row)
        if XBAssetManager.standard.selectedPhoto.contains(asset) {
            
            selectPhotoButton.isSelected = false
            selectImageView.image = cell.photoDefImage
            cell.selectedIndex = 0
            for (index, item) in XBAssetManager.standard.selectedPhoto.enumerated() {
                if item == asset {
                    XBAssetManager.standard.selectedPhoto.remove(at: index)
                    break
                }
            }
        } else {
            
            /// 超过最大选择数量
            if XBImagePickerConfiguration.shared.gridView.selectMaxNumber <= XBAssetManager.standard.selectedPhoto.count {
                self.navigationController?.view.shake()
                return
            }
            selectPhotoButton.isSelected = true
            selectImageView.image = cell.photoSelImage
            cell.selectedIndex = XBAssetManager.standard.selectedPhoto.count + 1
            selectImageView.showOscillatoryAnimation()
            XBAssetManager.standard.selectedPhoto.append(asset)
        }
        
        self.selectNumButtonItem.title = "\(XBAssetManager.standard.selectedPhoto.count)/\(XBImagePickerConfiguration.shared.gridView.selectMaxNumber)"
        self.collectionView.reloadItems(at: self.collectionView.visibleCells.compactMap { self.collectionView.indexPath(for: $0) }.filter { $0.row != indexPath.row })
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver
extension XBImageGridViewController: PHPhotoLibraryChangeObserver {
    
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
                guard let collectionView = self.collectionView else { fatalError() }
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
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // 如果增量差异不可用，重新加载集合视图.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
        
    }
}


// MARK: - UIScrollViewDelegate
extension XBImageGridViewController {
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}

// MARK: - Diff
extension XBImageGridViewController {
    
    /// 重置缓存资源
    private func resetCachedAssets() {
        XBAssetManager.standard.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    
    /// 刷新缓存资源
    private func updateCachedAssets() {
        
        // 仅在视图可见时更新
        guard isViewLoaded && view.window != nil else { return }
        
        // 预热视图的高度是可视矩形的两倍.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
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
        XBAssetManager.standard.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill)
        XBAssetManager.standard.stopCachingImages(for: removedAssets,
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
