//
//  TimeInterval+.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/31.
//  Copyright © 2019 Sky. All rights reserved.
//

import Foundation


// MARK: - 扩展TimeInterval
public extension TimeInterval {
    
    var minuteSecondMS: String {
        
        if millisecond > 500 {
            return String(format:"%d:%02d", minute, second + 1)
        } else {
            return String(format:"%d:%02d", minute, second)
        }
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        return Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}
