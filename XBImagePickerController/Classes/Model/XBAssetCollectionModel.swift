//
//  XBAssetCollectionModel.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/2/1.
//  Copyright © 2019 Sky. All rights reserved.
//

import Photos
import Foundation


/// MARK - 资源集合实体
public struct XBAssetCollectionModel {
    
    /// 资源集合
    let assetCollection: PHAssetCollection
    
    /// 资源数据
    let assets: PHFetchResult<PHAsset>
    
    
    /// 初始化资源集合实体
    ///
    /// - Parameters:
    ///   - assetCollection: assetCollection
    ///   - assets: assets
    init(assetCollection: PHAssetCollection, assets: PHFetchResult<PHAsset>) {
        self.assetCollection = assetCollection
        self.assets = assets
    }
}
