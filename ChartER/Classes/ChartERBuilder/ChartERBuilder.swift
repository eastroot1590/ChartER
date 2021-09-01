//
//  ChartERBuilder.swift
//  Pods
//
//  Created by 이동근 on 2021/08/31.
//

import Foundation

open class ChartERBuilder {
    /// 표시할 값 개수
    let visibleValuesCount: Int
    
    /// 축 크기
    var axisSize: CGSize = CGSize(width: 50, height: 50)
    /// series 크기
    var seriesSize: CGFloat = 2
    /// series 여백
    var seriesInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    /// series 좌표
    var seriesPoints: [CGPoint] = []
    
    public init(visibleValuesCount: Int = 7) {
        self.visibleValuesCount = visibleValuesCount
    }
    
    /// seriesPoints를 다시 계산
    func update(to index: Int, in bound: CGRect, with series: ChartERSeries) {
        guard let min = series.values.min(),
              let max = series.values.max() else {
            return
        }
        
        var points: [CGPoint] = []
        
        let seriesBound = CGSize(width: bound.width - axisSize.width - seriesInset.left - seriesInset.right, height: bound.height - axisSize.height - seriesInset.bottom - seriesInset.top)
        let spacing = seriesBound.width / CGFloat(visibleValuesCount - 1)
        var x: CGFloat = bound.minX + axisSize.width + seriesInset.left
        let minY = bound.minY + seriesInset.top
        
        for visibleIndex in 0 ..< visibleValuesCount {
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
        let spacing = seriesBound.width / CGFloat(visibleValuesCount - 1)
        var x: CGFloat = bound.minX + axisSize.width + seriesInset.left
        
        for _ in 0 ..< visibleValuesCount {
            let point = CGPoint(x: x, y: bound.maxY - axisSize.height)
            
            points.append(point)
            x += spacing
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
        
        for i in 0 ..< seriesPoints.count {
            markerPath.move(to: CGPoint(x: seriesPoints[i].x + 4, y: seriesPoints[i].y))
            markerPath.addArc(withCenter: seriesPoints[i], radius: 4, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        }
        
        return markerPath.cgPath
    }
    
//    func axis() -> CGPath {
//        let axisPath = UIBezierPath()
//
//        axisPath.move(to: CGPoint(x: chart.axisSize.width, y: 0))
//        axisPath.addLine(to: CGPoint(x: chart.axisSize.width, y: chart.frame.height - chart.axisSize.height))
//        axisPath.addLine(to: CGPoint(x: chart.frame.width - chart.chartInset.right, y: chart.frame.height - chart.axisSize.height))
//
//        return axisPath.cgPath
//    }
//
//    func xAxisLabels() -> [CATextLayer] {
//        var labels: [CATextLayer] = []
//
//        var x: CGFloat = chart.axisSize.width + chart.chartInset.left
//
//        for _ in 0 ..< chart.visibleValuesCount {
//            let y = chart.frame.height - chart.axisSize.height + 5
//
//            let label = CATextLayer()
//            label.string = "nil"
//            label.frame = CGRect(origin: CGPoint(x: x - 20, y: y), size: CGSize(width: 40, height: chart.axisSize.height - 5))
//            label.font = UIFont.systemFont(ofSize: 8)
//            label.alignmentMode = .center
//            label.fontSize = 12
//            label.contentsScale = UIScreen.main.scale
//            label.foregroundColor = UIColor.gray.cgColor
//            labels.append(label)
//
//            x += chart.spacing
//        }
//
//        return labels
//    }
//
//    func yAxisLabels() -> [CATextLayer] {
//        var labels: [CATextLayer] = []
//
//        for index in 0 ..< 4 {
//            let alpha = Float(index) / 3
//            let value = lerp(chart.maxValue, chart.minValue, alpha)
//            let y = lerp(chart.chartInset.top, chart.chartInset.top + chart.chartSize.height, CGFloat(alpha))
//
//            let label = CATextLayer()
//            label.string = "\(Int(value))"
//            label.frame = CGRect(origin: CGPoint(x: 0, y: y - 7), size: CGSize(width: chart.axisSize.width - 5, height: 14))
//            label.font = UIFont.systemFont(ofSize: 8)
//            label.alignmentMode = .right
//            label.fontSize = 12
//            label.contentsScale = UIScreen.main.scale
//            label.foregroundColor = UIColor.gray.cgColor
//            labels.append(label)
//        }
//
//        return labels
//    }
//
//    func seriesLabels() -> [CATextLayer] {
//        var labels: [CATextLayer] = []
//
//        for _ in 0 ..< chart.visibleValuesCount {
//            let label = CATextLayer()
//            label.font = UIFont.systemFont(ofSize: 12)
//            label.fontSize = 12
//            label.alignmentMode = .center
//            label.contentsScale = UIScreen.main.scale
//            label.foregroundColor = chart.axisColor
//            labels.append(label)
//        }
//
//        return labels
//    }
//
//    func updateSeriesLabel(_ seriesLabels: [CATextLayer], at index: Int, animated: Bool =  true) {
//        var x: CGFloat = chart.chartInset.left + chart.axisSize.width
//
//        for offset in 0 ..< chart.visibleValuesCount {
//            let seriesLabel = seriesLabels[offset]
//            let point: CGPoint = CGPoint(x: x, y: getY(at: index + offset))
//            let value = chart.series.values[index + offset]
//            let targetFrame = CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 20)
//            let targetString = "\(Int(value))"
//
//            let frameAnimation = CABasicAnimation(keyPath: "frame")
//            frameAnimation.fromValue = seriesLabel.frame
//            frameAnimation.toValue = targetFrame
//            frameAnimation.duration = chart.animateDuration
//            seriesLabel.add(frameAnimation, forKey: "frame")
//
//            seriesLabel.frame = targetFrame
//            seriesLabel.string = targetString
//
//            x += chart.spacing
//        }
//    }
//
//    func chartPath(at index: Int) -> CGPath {
//        UIBezierPath().cgPath
//    }
//
//    func pointPath(at index: Int) -> CGPath {
//        let pointPath = UIBezierPath()
//
//        var x: CGFloat = chart.chartInset.left + chart.axisSize.width
//
//        for offset in 0 ..< chart.visibleValuesCount {
//            let point: CGPoint = CGPoint(x: x, y: getY(at: index + offset))
//
//            let radius: CGFloat = 5
//            pointPath.move(to: CGPoint(x: point.x + radius, y: point.y))
//            pointPath.addArc(withCenter: point, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
//
//            x += chart.spacing
//        }
//
//        return pointPath.cgPath
//    }
//
//    func getY(at index: Int) -> CGFloat {
//        let value = chart.series.values[index]
//        let yOffset = (chart.maxValue - chart.minValue) != 0 ? (value - chart.minValue) / (chart.maxValue - chart.minValue) : 0
//
//        return chart.chartInset.top + CGFloat(1 - yOffset) * chart.chartSize.height
//    }
}
