//
//  ChartERBuilder.swift
//  Pods
//
//  Created by 이동근 on 2021/08/31.
//

import Foundation

open class ChartERBuilder {
    /// x 축 라벨 개수
    let xAxisLabelCount: Int
    /// y 축 라벨 개수
    let yAxisLabelCount: Int
    
    /// 축 크기
    var axisSize: CGSize = CGSize(width: 50, height: 50)
    /// series 크기
    var seriesSize: CGFloat = 2
    /// series 여백
    var seriesInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    /// series 좌표
    var seriesPoints: [CGPoint] = []
    
    public init(xAxisLabelCount: Int = 7, yAxisLabelCount: Int = 4) {
        self.xAxisLabelCount = xAxisLabelCount
        self.yAxisLabelCount = yAxisLabelCount
    }
    
    /// seriesPoints를 다시 계산
    func update(to index: Int, in bound: CGRect, with series: ChartERSeries) {
        guard let min = series.values.min(),
              let max = series.values.max() else {
            return
        }
        
        var points: [CGPoint] = []
        
        let seriesBound = CGSize(width: bound.width - axisSize.width - seriesInset.left - seriesInset.right, height: bound.height - axisSize.height - seriesInset.bottom - seriesInset.top)
        let spacing = seriesBound.width / CGFloat(xAxisLabelCount - 1)
        var x: CGFloat = bound.minX + axisSize.width + seriesInset.left
        let minY = bound.minY + seriesInset.top
        
        for visibleIndex in 0 ..< xAxisLabelCount {
            let alpha = reverseLerp(min, max, series.values[index + visibleIndex])
            let point = CGPoint(x: x, y: minY + CGFloat(1 - alpha) * seriesBound.height)
            
            points.append(point)
            x += spacing
        }
        
        seriesPoints = points
    }
    
    func axisPath(in bound: CGRect) -> CGPath {
        let axisPath = UIBezierPath()
        
        axisPath.move(to: CGPoint(x: bound.minX + axisSize.width, y: bound.minY))
        axisPath.addLine(to: CGPoint(x: bound.minX + axisSize.width, y: bound.maxY - axisSize.height))
        axisPath.addLine(to: CGPoint(x: bound.maxX, y: bound.maxY - axisSize.height))
        
        return axisPath.cgPath
    }
    
    func xAxisLabelPoints(in bound: CGRect) -> [CGPoint] {
        var points: [CGPoint] = []
        
        let seriesBound = CGSize(width: bound.width - axisSize.width - seriesInset.left - seriesInset.right, height: bound.height - axisSize.height - seriesInset.bottom - seriesInset.top)
        let spacing = seriesBound.width / CGFloat(xAxisLabelCount - 1)
        var x: CGFloat = bound.minX + axisSize.width + seriesInset.left
        
        for _ in 0 ..< xAxisLabelCount {
            let point = CGPoint(x: x, y: bound.maxY - axisSize.height)
            
            points.append(point)
            x += spacing
        }
        
        return points
    }
    
    func yAxisLabelInfos(in bound: CGRect) -> [CGPoint] {
        var points: [CGPoint] = []
        
        let minY = bound.minY + seriesInset.top
        let maxY = bound.maxY - axisSize.height - seriesInset.bottom
        
        for index in 0 ..< yAxisLabelCount {
            let y = lerp(minY, maxY, CGFloat(index) / CGFloat(yAxisLabelCount - 1))
            let point = CGPoint(x: bound.minX + axisSize.width, y: y)
            
            points.append(point)
        }
        
        return points
    }
    
    func seriesPath(in bound: CGRect) -> CGPath {
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
    
    func markerPath() -> CGPath {
        let markerPath = UIBezierPath()
        
        seriesPoints.forEach { point in
            markerPath.move(to: CGPoint(x: point.x + 4, y: point.y))
            markerPath.addArc(withCenter: point, radius: 4, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        }
        
        return markerPath.cgPath
    }
    
}
