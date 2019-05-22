//
//  AssetManager.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import Photos
import Foundation


/// MARK - 资源管理类
open class AssetManager {
    
    /// 获取单利XBAssetManager
    public static let standard = AssetManager()
    
    /// 图像缓存管理器
    private lazy var imageManager: PHCachingImageManager = {
        let temImageManager = PHCachingImageManager()
        return temImageManager
    }()
    
    /// 图片请求配置选项
    private(set) lazy var options: PHImageRequestOptions = {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        return requestOptions
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
}


// MARK: - 缓存资源
extension AssetManager {
    
    /// 请求图片
    ///
    /// - Parameters:
    ///   - asset: 资产
    ///   - targetSize: 目标大小
    ///   - contentMode: 内容模式
    ///   - resultHandler: resultHandler
    public func requestImage(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        
        self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { image, info in
            resultHandler(image, info)
        })
    }
    
    
    /// 开始缓存图片
    ///
    /// - Parameters:
    ///   - assets: 资源
    ///   - targetSize: 目前大小
    ///   - contentMode: 内容模式
    ///   - options: options
    public func startCachingImages(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode) {
        self.imageManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: options)
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
    
    /// MARK - 停止缓存图片资源
    public func stopCachingImagesForAllAssets() {
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.imageManager.stopCachingImagesForAllAssets()
        }
    }
}



// MARK: - 获取相册资源
extension AssetManager {
    
    
    /// 获取相册资源
    ///
    /// - Parameters:
    ///   - libraryMediaType: 资源类型
    ///   - sort: 排序
    ///   - completion: 完成回调
    public func fetchAlbums(_ libraryMediaType: LibraryMediaType,
                            sort: Bool,
                            completion: @escaping ([AssetCollection]) -> Void) {
        
        DispatchQueue.global().async {
            
            let allAlbums = self.fetchAllAlbums()
            var array: [PHAssetCollection] = []
            
            switch libraryMediaType {
            case .all:
                array = allAlbums
            case .image:
                array = allAlbums.filter { $0.assetCollectionSubtype != .smartAlbumVideos }
            case .video:
                array = allAlbums.filter { $0.assetCollectionSubtype == .smartAlbumVideos }
            }
            
            
            let result = array.map { assetCollection -> AssetCollection in
                
                let assets = self.fetchGridAsset(in: assetCollection, sort: sort, libraryMediaType: libraryMediaType)
                return AssetCollection(assetCollection: assetCollection, assets: assets)
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    
    /// 获取资源集合对象的项
    ///
    /// - Parameters:
    ///   - assetCollection: 资源集合
    ///   - sortAscendingByModificationDate: 按修改日期升序排序
    ///   - libraryMediaType: 资源类型
    /// - Returns: 资源项
    private func fetchGridAsset(in assetCollection: PHAssetCollection,
                                sort: Bool,
                                libraryMediaType: LibraryMediaType) -> PHFetchResult<PHAsset> {
        
        var result: PHFetchResult<PHAsset>!
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sort)]
        switch libraryMediaType {
        case .all:
            result = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
        case .image:
            allPhotosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            result = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
        case .video:
            allPhotosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            result = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
        }
        return result
    }
    
    
    /// 获取所有相册
    ///
    /// - Returns: 相册集合
    private func fetchAllAlbums() -> [PHAssetCollection] {
        
        var array: [PHAssetCollection] = []
        array.append(contentsOf: fetchSmartAlbums())
        array.append(contentsOf: fetchUserAlbums())
        return array
    }
    
    
    /// 获取系统智能归纳的相册
    ///
    /// - Returns: 相册集合
    private func fetchSmartAlbums() -> [PHAssetCollection] {
        
        var array: [PHAssetCollection] = []
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        smartAlbums.enumerateObjects { (collection, index, stop) in
            
            /*
             1.判断是否是隐藏相册
             2.判断是否是最近删除相册
             */
            guard collection.assetCollectionSubtype != .smartAlbumAllHidden,
                collection.assetCollectionSubtype.rawValue != 1000000201 else {
                    return
            }
            
            //判断相册数量是否大于0
            if collection.photosCount > 0 {
                
                // 所有照片移到第一位
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    array.insert(collection, at: 0)
                } else {
                    array.append(collection)
                }
            }
        }
        
        return array
    }
    
    
    /// 拉取用户自定义相册
    ///
    /// - Returns: 相册集合
    private func fetchUserAlbums() -> [PHAssetCollection] {
        
        var array: [PHAssetCollection] = []
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        userAlbums.enumerateObjects { (collection, index, stop) in
            
            if collection.photosCount > 0 {
                array.append(collection)
            }
        }
        return array
    }
}


// MARK: - 权限
extension AssetManager {
    
    /// 检查访问照片库的权限
    ///
    /// - Parameter block: block description
    public func checkPermissionToAccessPhotoLibrary(block: @escaping (Bool) -> Void) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            block(true)
        case .restricted, .denied:
            block(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { s in
                DispatchQueue.main.async {
                    block(s == .authorized)
                }
            }
        @unknown default:
            fatalError()
        }
    }
}



//// MARK: - PHAssetCollection func
//extension XBAssetManager {
//
//
//
//
//    /// 获取集合资源
//    ///
//    /// - Parameters:
//    ///   - assetCollection: 资源对象
//    ///   - sortAscendingByModificationDate: 照片排序
//    ///   - libraryMediaType: 资源类型
//    public func fetchGridAsset(in assetCollection: PHAssetCollection?, sortAscendingByModificationDate: Bool, libraryMediaType: XBLibraryMediaType, block: @escaping (PHFetchResult<PHAsset>) -> Void) {
//
//        self.operationQueue.addOperation {
//
//            var result: PHFetchResult<PHAsset>!
//            let allPhotosOptions = PHFetchOptions()
//            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)]
//            if let temAssetCollection = assetCollection {
//
//                switch libraryMediaType {
//                case .all:
//                    result = PHAsset.fetchAssets(in: temAssetCollection, options: allPhotosOptions)
//                case .image:
//                    allPhotosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
//                    result = PHAsset.fetchAssets(in: temAssetCollection, options: allPhotosOptions)
//                case .video:
//                    allPhotosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
//                    result = PHAsset.fetchAssets(in: temAssetCollection, options: allPhotosOptions)
//                }
//
//            } else {
//
//                switch libraryMediaType {
//                case .all:
//                    result = PHAsset.fetchAssets(with: allPhotosOptions)
//                case .image:
//                    result = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
//                case .video:
//                    result = PHAsset.fetchAssets(with: .video, options: allPhotosOptions)
//                }
//            }
//
//            DispatchQueue.main.async {
//                block(result)
//            }
//        }
//    }
//
//
//    /// 获取字资源
//    ///
//    /// - Parameters:
//    ///   - assetCollection: <#assetCollection description#>
//    ///   - sortAscendingByModificationDate: <#sortAscendingByModificationDate description#>
//    /// - Returns: <#return value description#>
//    public func fetchAsset(in assetCollection: PHAssetCollection, sortAscendingByModificationDate: Bool) -> PHFetchResult<PHAsset> {
//
//        let options = PHFetchOptions()
//        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)]
//        return PHAsset.fetchAssets(in: assetCollection, options: options)
//    }
//}
