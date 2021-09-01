//
//  LineChartERBuilder.swift
//  Pods
//
//  Created by 이동근 on 2021/08/31.
//

import Foundation

/// 꺾은선 차트 Path를 만들 수 있는 Builder
open class LineChartERBuilder: ChartERBuilder {
    var lastPoint: CGPoint = .zero
    
    var curveRate: CGFloat = 0
    
    override func seriesPath(in bound: CGRect) -> CGPath {
        let seriesPath = UIBezierPath()
        
        for i in 0 ..< seriesPoints.count {
            if i == 0 {
                seriesPath.move(to: seriesPoints[i])
            } else {
                seriesPath.addLine(to: seriesPoints[i])
            }
        }
        
        return seriesPath.cgPath
    }
}
