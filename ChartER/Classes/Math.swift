//
//  Math.swift
//  Pods
//
//  Created by 이동근 on 2021/08/31.
//

import Foundation

@inlinable public func clamp<T>(_ value: T, _ minValue: T, _ maxValue: T) -> T where T: Comparable {
    return min(max(value, minValue), maxValue)
}

@inlinable public func lerp<T>(_ lhs: T, _ rhs: T, _ alpha: T) -> T where T: Numeric {
    return lhs * (1 - alpha) + rhs * alpha
}
