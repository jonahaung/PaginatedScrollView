//
//  Refresher.swift
//  MyBike
//
//  Created by Aung Ko Min on 17/1/22.
//

import SwiftUI

public extension PaginatedScrollViewManager {
    
    struct Refresher {
        
        enum RefreshStatus {
            case invalid, valid, preparing, refreshing
        }
        
        var threshold: CGFloat = 140
        var offsetY = CGFloat.zero
        
        private var refreshStatus = RefreshStatus.invalid
        var progressValue = 0.0
        
        mutating func canRefresh(for value: CGFloat) -> Bool {
            var result = false
            switch refreshStatus {
            case .invalid:
                if value > 20 && offsetY <= 20 {
                    refreshStatus = .valid
                }
            case .valid:
                if value > threshold && offsetY <= threshold {
                    refreshStatus = .preparing
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            case .preparing:
                if offsetY > threshold && value <= threshold {
                    result = true
                    refreshStatus = .refreshing
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            case .refreshing:
                break
            }
            offsetY = value
            progressValue = calculateProgress(value)
            return result
        }
        
        private func calculateProgress(_ scrollOffset: CGFloat) -> CGFloat {
            
            let percent = 0.01
            if scrollOffset < threshold * percent {
                return 0
            } else {
                let h = Double(threshold)
                let d = Double(scrollOffset)
                let v = max(min(d - (h * percent), h * 1-percent), 0)
                let value = 100 * v / (h * 1-percent)
                
                return value
            }
        }
        
        mutating func reset() {
            refreshStatus = .invalid
            progressValue = 0
        }
    }
}
