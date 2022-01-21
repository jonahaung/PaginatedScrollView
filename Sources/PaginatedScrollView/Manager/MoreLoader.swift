//
//  MoreLoader.swift
//  MyBike
//
//  Created by Aung Ko Min on 17/1/22.
//

import SwiftUI

public extension PaginatedScrollViewManager {
    
    struct MoreLoader {
        
        var canLoadMore = true
        
        var threshold: CGFloat = 50
        
        func canLoadMore(for value: CGFloat) -> Bool {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            return canLoadMore
        }
    }
}
