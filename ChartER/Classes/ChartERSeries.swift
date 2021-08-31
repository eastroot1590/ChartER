//
//  ChartERValues.swift
//  ChartERView
//
//  Created by 이동근 on 2021/08/30.
//

import Foundation

/// 차트에 표시할 수 있는 값들의 집합
public struct ChartERSeries {
    public static let empty: ChartERSeries = ChartERSeries(name: nil, values: [])
    
    let name: String?
    let values: [Float]
    
    public init(name: String?, values: [Float]) {
        self.name = name
        self.values = values
    }
}
