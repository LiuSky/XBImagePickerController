//
//  AssetModel.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/2/1.
//  Copyright © 2019 Sky. All rights reserved.
//

import Photos
import Foundation


/// MARK - 资源集合实体
public class AssetCollection {
    
    /// 资源集合
    let assetCollection: PHAssetCollection
    
    /// 资源数据
    let assets: [Asset]
    
    /// 选中数量
    var selectedCount: Int
    
    
    /// 初始化资源集合实体
    ///
    /// - Parameters:
    ///   - assetCollection: assetCollection
    ///   - assets: assets
    init(assetCollection: PHAssetCollection, assets: [Asset], selectedCount: Int = 0) {
        self.assetCollection = assetCollection
        self.assets = assets
        self.selectedCount = selectedCount
    }
}


/// MARK - 资源实体
public class Asset {
    
    /// 资源
    let asset: PHAsset
    
    /// 是否选中(默认为false)
    var isSelected: Bool
    
    
    /// 初始化资源实体
    ///
    /// - Parameters:
    ///   - asset: 资源对象
    ///   - isSelected: 是否选中
    init(asset: PHAsset, isSelected: Bool = false) {
        self.asset = asset
        self.isSelected = isSelected
    }
}
