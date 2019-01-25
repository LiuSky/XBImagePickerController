//
//  UICollectionView+.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


// MARK: - <#Description#>
public extension UICollectionView {
    
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
