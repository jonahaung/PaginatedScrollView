//
//  CustomScrollViewKeys.swift
//  MyBike
//
//  Created by Aung Ko Min on 13/1/22.
//

import SwiftUI

public typealias LoadMoreAction = (@Sendable (_ canLoad: Binding<Bool>) async -> Void)
public typealias ReloadAction = (@Sendable () async -> Void)

public struct PaginatedScrollViewKey {
    
    enum Direction {
        case top, bottom
    }
    
    struct PreData: Equatable {
        static var fraction = CGFloat(0.001)
        
        let top: CGFloat
        let bottom: CGFloat
        
        private var abTop: CGFloat { abs(min(0, top)) }
        private var abBottom: CGFloat { abs(max(0, bottom)) }
        
        var position: Direction {
            return abTop > abBottom ? .bottom : .top
        }
    
        var isAtTop: Bool {
            let percentage = abs(top / contentHeight)
            return percentage < PreData.fraction
        }
        
        var isAtBottom: Bool {
            let percentage = (bottom / contentHeight)
            return percentage < PreData.fraction
        }
        
        private var contentHeight: CGFloat {
            abs(top - bottom)
        }
    }
    
    struct PreKey: PreferenceKey {
        static var defaultValue: PreData? = nil
        static func reduce(value: inout PreData?, nextValue: () -> PreData?) {}
    }
}

// Load More
struct LoadMoreKey: EnvironmentKey {
    static let defaultValue: LoadMoreAction? = nil
}

extension EnvironmentValues {
    var loadMore: LoadMoreAction? {
        get { self[LoadMoreKey.self] }
        set { self[LoadMoreKey.self] = newValue }
    }
}
extension View {
    public func moreLoadable(action: @escaping LoadMoreAction) -> some View {
        environment(\.loadMore, action)
    }
}
// Reload

struct ReloadKey: EnvironmentKey {
    static let defaultValue: ReloadAction? = nil
}

extension EnvironmentValues {
    var reload: ReloadAction? {
        get { self[ReloadKey.self] }
        set { self[ReloadKey.self] = newValue }
    }
}
extension View {
    public func relodable(action: @escaping ReloadAction) -> some View {
        environment(\.reload, action)
    }
}
