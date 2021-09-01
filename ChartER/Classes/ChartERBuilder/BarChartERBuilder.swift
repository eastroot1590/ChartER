//
//  BarChartERBuilder.swift
//  Pods
//
//  Created by 이동근 on 2021/08/31.
//

import Foundation

/// 바 차트 Path를 만들 수 있는 Builder
open class BarChartERBuilder: ChartERBuilder {
    public init(size: CGFloat = 20) {
        super.init()
        
        chartSize = size
    }
    
    override func chartPath(at index: Int) -> CGPath {
        let chartPath = UIBezierPath()
        
        var x: CGFloat = chart.chartInset.left + chart.axisSize.width
        
        for offset in 0 ..< chart.visibleValuesCount {
            let point: CGPoint = CGPoint(x: x, y: getY(at: index + offset))
            
            // bar
            chartPath.move(to: CGPoint(x: point.x, y: chart.chartInset.top + chart.chartSize.height))
            chartPath.addLine(to: point)
            
            x += chart.spacing
        }
        
        return chartPath.cgPath
    }
}
