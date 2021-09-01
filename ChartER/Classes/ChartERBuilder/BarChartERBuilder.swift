//
//  BarChartERBuilder.swift
//  Pods
//
//  Created by 이동근 on 2021/08/31.
//

import Foundation

/// 바 차트 Path를 만들 수 있는 Builder
open class BarChartERBuilder: ChartERBuilder {
    override public init(visibleValuesCount: Int) {
        super.init(visibleValuesCount: visibleValuesCount)
        
        seriesSize = 20
    }
    
    override func seriesPath(in bound: CGRect) -> CGPath {
        let barPath = UIBezierPath()
        
        for i in 0 ..< visibleValuesCount {
            // bar
            barPath.move(to: seriesPoints[i])
            barPath.addLine(to: CGPoint(x: seriesPoints[i].x, y: bound.maxY - axisSize.height))
        }
        
        return barPath.cgPath
    }
}
