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
    
    override func chartPath(at index: Int) -> CGPath {
        let chartPath = UIBezierPath()
        
        var x: CGFloat = chart.chartInset.left + chart.axisSize.width
        
        for offset in 0 ..< chart.visibleValuesCount {
            let point: CGPoint = CGPoint(x: x, y: getY(at: index + offset))
            
            // line
            if offset == 0 {
                chartPath.move(to: point)
            } else {
                // curve
                let offset = (chart.spacing / 2) * (1 - curveRate)
                chartPath.addCurve(to: point, controlPoint1: CGPoint(x: lastPoint.x + offset, y: lastPoint.y), controlPoint2: CGPoint(x: point.x - offset, y: point.y))
                // line
//                linePath.addLine(to: point)
            }
            lastPoint = point
            
            x += chart.spacing
        }
        
        return chartPath.cgPath
    }
}
