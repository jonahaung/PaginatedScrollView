//
//  File.swift
//  
//
//  Created by Aung Ko Min on 17/1/22.
//

import UIKit

public struct PaginatedScrollViewSettings {
    
    public var moreLoaderTreshold: CGFloat
    public var reloaderTreshold: CGFloat
    public var atTopPercent: CGFloat
    public var atBottomPercent: CGFloat
    public var preferenceChangeTimeInterval: Int64
    
    public static let defaultSettings = PaginatedScrollViewSettings(moreLoaderTreshold: 50, reloaderTreshold: 140, atTopPercent: 1.0, atBottomPercent: 0.01, preferenceChangeTimeInterval: 30)
}
