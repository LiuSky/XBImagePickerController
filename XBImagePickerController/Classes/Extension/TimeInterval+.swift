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
    
    /// 时间字符串
    public var timeString: String {
        
        let duration = Int64(self)
        if duration < 10 {
            return String(format: "0:0%zd", duration)
        } else if duration < 60 {
            return String(format: "0:%zd", duration)
        } else {
            
            let min = duration / 60
            let sec = duration - (min * 60)
            if sec < 10 {
                return String(format: "%zd:0%zd", min, sec)
            } else {
                return String(format: "%zd:%zd", min, sec)
            }
        }
    }
}
