//
//  XBGridViewController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Photos
import PhotosUI


/// 允许选择资源类型
///
/// - all: 所有
/// - image: 图片
/// - video: 视屏
public enum XBAllowPickingMediaType: Int, CustomStringConvertible {
    
    case all
    case image
    case video
    
    
    /// description
    public var description: String {
        switch self {
        case .all:
            return "所有资源"
        case .image:
            return "图片"
        case .video:
            return "视频"
        }
    }
}


/// MARK - XBGridViewController
public class XBGridViewController: UICollectionViewController, Animation {

    /// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
    public var sortAscendingByModificationDate: Bool = true
    
    /// 允许选择资源类型
    public var allowPickingMediaType: XBAllowPickingMediaType = XBAllowPickingMediaType.all
    
    /// 一行显示几个默认(4个)
    public var numberOfColumns = 4
    
    /// 默认行间距
    public var minimumLineSpacing = 1
    
    /// 默认列间距
    public var minimumInteritemSpacing = 1
    
    /// 拉取照片结果
    private lazy var fetchResult: PHFetchResult<PHAsset> = {
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)]
        switch self.allowPickingMediaType {
        case .all:
            return PHAsset.fetchAssets(with: allPhotosOptions)
        case .image:
            return PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        case .video:
            return PHAsset.fetchAssets(with: .video, options: allPhotosOptions)
        }
    }()
    
    
    /// 图像缓存管理器
    private let imageManager = PHCachingImageManager()
    
    /// 选中照片
    private var selectedPhoto: [PHAsset] = []
    
    /// 之前的预热矩形
    private var previousPreheatRect = CGRect.zero
    
    /// 每个ItemSize
    private lazy var itemSize: CGSize = {
        
        let spacing: CGFloat = CGFloat((self.numberOfColumns - 1) * self.minimumInteritemSpacing)
        let width = (UIScreen.main.bounds.size.width - spacing) / CGFloat(self.numberOfColumns)
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
        temFlowLayout.minimumLineSpacing = CGFloat(self.minimumLineSpacing)
        temFlowLayout.minimumInteritemSpacing = CGFloat(self.minimumInteritemSpacing)
        return temFlowLayout
    }()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        self.view.backgroundColor = UIColor.white
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(XBGridCell.self, forCellWithReuseIdentifier: XBGridCell.identifier)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionView.collectionViewLayout = self.flowLayout
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}


// MARK: - UICollectionViewDataSource
extension XBGridViewController {
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.fetchResult.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XBGridCell.identifier, for: indexPath) as! XBGridCell
        cell.delegate = self
        cell.photoSelImage = #imageLiteral(resourceName: "photoSelImage")
        cell.photoDefImage = #imageLiteral(resourceName: "photoDefImage")
        
        let asset = fetchResult.object(at: indexPath.item)
        
        /// 匹配是否有选中的数量
        var selectedIndex = 0
        for (index, item) in self.selectedPhoto.enumerated() {
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
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
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
extension XBGridViewController {
    
}


// MARK: - XBGridCellDelegate
extension XBGridViewController: XBGridCellDelegate {
    
    public func selectPhoto(_ cell: XBGridCell, selectImageView: UIImageView, selectPhotoButton: UIButton) {
        
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return
        }
        
        let asset = self.fetchResult.object(at: indexPath.row)
        if self.selectedPhoto.contains(asset) {
            
            selectPhotoButton.isSelected = false
            selectImageView.image = cell.photoDefImage
            cell.selectedIndex = 0
            for (index, item) in self.selectedPhoto.enumerated() {
                if item == asset {
                    self.selectedPhoto.remove(at: index)
                    break
                }
            }
        } else {
            selectPhotoButton.isSelected = true
            selectImageView.image = cell.photoSelImage
            cell.selectedIndex = self.selectedPhoto.count + 1
            self.showOscillatoryAnimation(selectImageView)
            self.selectedPhoto.append(asset)
        }
        
        self.collectionView.reloadItems(at: self.collectionView.visibleCells.compactMap { self.collectionView.indexPath(for: $0) }.filter { $0.row != indexPath.row })
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver
extension XBGridViewController: PHPhotoLibraryChangeObserver {
    
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
extension XBGridViewController {
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}

// MARK: - Diff
extension XBGridViewController {
    
    
    /// 重置缓存资源
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
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
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
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
