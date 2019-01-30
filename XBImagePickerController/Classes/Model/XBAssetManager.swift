//
//  XBAssetManager.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import Photos
import Foundation


/// MARK - 资源管理类
open class XBAssetManager {
    
    /// 获取单利XBAssetManager
    public static let standard = XBAssetManager()
    
    /// 图像缓存管理器
    private lazy var imageManager: PHCachingImageManager = {
        let temImageManager = PHCachingImageManager()
        return temImageManager
    }()
    
    /// 操作队列
    private lazy var operationQueue: OperationQueue = {
        let temOperationQueue = OperationQueue()
        temOperationQueue.maxConcurrentOperationCount = 50
        return temOperationQueue
    }()
    
    /// 选中照片
    public var selectedPhoto: [PHAsset] = [] {
        didSet {
            
            for item in oldValue {
                self.stopCachingImages(for: oldValue,
                                       targetSize: CGSize(width: item.pixelWidth, height: item.pixelHeight), contentMode: PHImageContentMode.aspectFill)
            }
            
            for item in selectedPhoto {
                self.startCachingImages(for: [item],
                                            targetSize: CGSize(width: item.pixelWidth, height: item.pixelHeight), contentMode: PHImageContentMode.aspectFill)
            }
        }
    }
    
    init() {}
    
    
    /// 获取所有相册
    ///
    /// - Returns: return value description
    public func allAlbums() -> [PHAssetCollection] {
        
        /// 智能相册
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        var temArray: [PHAssetCollection] = []
        smartAlbums.enumerateObjects { (collection, index, stop) in
            
            //1.判断是否是隐藏相册, 2.判断是否是最近删除相册
            guard collection.assetCollectionSubtype != .smartAlbumAllHidden,
                  collection.assetCollectionSubtype.rawValue != 1000000201 else {
                    return
            }
            
            if collection.photosCount > 0 {
                
                // 所有照片移到第一位
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    temArray.insert(collection, at: 0)
                } else {
                    temArray.append(collection)
                }
            }
        }
        
        /// 用户自定义相册
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        userAlbums.enumerateObjects { (collection, index, stop) in
            
            if collection.photosCount > 0 {
                temArray.append(collection)
            }
        }
        
        return temArray
    }
    
    
    /// 获取资产
    ///
    /// - Returns: <#return value description#>
    public func fetchAssets(in assetCollection: PHAssetCollection, options: PHFetchOptions?) -> PHFetchResult<PHAsset> {

        return PHAsset.fetchAssets(in: assetCollection, options: options)
    }
    
    
    /// 请求图片
    ///
    /// - Parameters:
    ///   - asset: 资产
    ///   - targetSize: 目标大小
    ///   - contentMode: 内容模式
    ///   - resultHandler: resultHandler
    public func requestImage(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        self.operationQueue.addOperation {
            self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { image, info in
                
                DispatchQueue.main.async {
                   resultHandler(image, info)
                }
            })
        }
    }
    
    
    /// MARK - 停止缓存图片资源
    public func stopCachingImagesForAllAssets() {
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    
    /// 开始缓存图片
    ///
    /// - Parameters:
    ///   - assets: 资源
    ///   - targetSize: 目前大小
    ///   - contentMode: 内容模式
    ///   - options: options
    public func startCachingImages(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode) {
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        self.imageManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: requestOptions)
    }
    
    
    /// 停止缓存图片
    ///
    /// - Parameters:
    ///   - assets: 资源
    ///   - targetSize: 目前大小
    ///   - contentMode: 内容模式
    ///   - options: options
    public func stopCachingImages(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode) {
        self.imageManager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: nil)
    }
}
