//
//  ChartERBuilder.swift
//  Pods
//
//  Created by 이동근 on 2021/08/31.
//

import Foundation

open class ChartERBuilder {
    var chart: ChartERView!
    
    /// 선, 바, 원 등 차트의 각 값을 표현하는 그래픽의 크기
    var chartSize: CGFloat = 2
    
    public init() {
        
    }
    
    func axis() -> CGPath {
        let axisPath = UIBezierPath()
        
        axisPath.move(to: CGPoint(x: chart.axisSize.width, y: 0))
        axisPath.addLine(to: CGPoint(x: chart.axisSize.width, y: chart.frame.height - chart.axisSize.height))
        axisPath.addLine(to: CGPoint(x: chart.frame.width - chart.chartInset.right, y: chart.frame.height - chart.axisSize.height))
        
        return axisPath.cgPath
    }
    
    func xAxisLabels() -> [CATextLayer] {
        var labels: [CATextLayer] = []
        
        var x: CGFloat = chart.axisSize.width + chart.chartInset.left
        
        for _ in 0 ..< chart.visibleValuesCount {
            let y = chart.frame.height - chart.axisSize.height + 5
            
            let label = CATextLayer()
            label.string = "nil"
            label.frame = CGRect(origin: CGPoint(x: x - 20, y: y), size: CGSize(width: 40, height: chart.axisSize.height - 5))
            label.font = UIFont.systemFont(ofSize: 8)
            label.alignmentMode = .center
            label.fontSize = 12
            label.contentsScale = UIScreen.main.scale
            label.foregroundColor = UIColor.gray.cgColor
            labels.append(label)
            
            x += chart.spacing
        }
        
        return labels
    }
    
    func yAxisLabels() -> [CATextLayer] {
        var labels: [CATextLayer] = []
        
        for index in 0 ..< 4 {
            let alpha = Float(index) / 3
            let value = lerp(chart.maxValue, chart.minValue, alpha)
            let y = lerp(chart.chartInset.top, chart.chartInset.top + chart.chartSize.height, CGFloat(alpha))
            
            let label = CATextLayer()
            label.string = "\(Int(value))"
            label.frame = CGRect(origin: CGPoint(x: 0, y: y - 7), size: CGSize(width: chart.axisSize.width - 5, height: 14))
            label.font = UIFont.systemFont(ofSize: 8)
            label.alignmentMode = .right
            label.fontSize = 12
            label.contentsScale = UIScreen.main.scale
            label.foregroundColor = UIColor.gray.cgColor
            labels.append(label)
        }
        
        return labels
    }
    
    func chartPath(at index: Int) -> CGPath {
        UIBezierPath().cgPath
    }
    
    func pointPath(at index: Int) -> CGPath {
        let pointPath = UIBezierPath()
        
        var x: CGFloat = chart.chartInset.left + chart.axisSize.width
        
        for offset in 0 ..< chart.visibleValuesCount {
            let point: CGPoint = CGPoint(x: x, y: getY(at: index + offset))
            
            let radius: CGFloat = 5
            pointPath.move(to: CGPoint(x: point.x + radius, y: point.y))
            pointPath.addArc(withCenter: point, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            
            x += chart.spacing
        }
        
        return pointPath.cgPath
    }
    
    func getY(at index: Int) -> CGFloat {
        let value = chart.series.values[index]
        let yOffset = (chart.maxValue - chart.minValue) != 0 ? (value - chart.minValue) / (chart.maxValue - chart.minValue) : 0
        
        return chart.chartInset.top + CGFloat(1 - yOffset) * chart.chartSize.height
    }
}
