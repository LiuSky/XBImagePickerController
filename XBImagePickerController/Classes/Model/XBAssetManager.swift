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
    public let imageManager = PHCachingImageManager()
    
    init() {
        
    }
    
    
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
    ///   - options: options
    ///   - resultHandler: resultHandler
    /// - Returns: PHImageRequestID
    @discardableResult
    public func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        
        return self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { image, info in
            resultHandler(image, info)
        })
    }
}
