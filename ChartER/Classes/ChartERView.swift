//
//  ChartERView.swift
//  ChartERView
//
//  Created by 이동근 on 2021/08/30.
//

import UIKit

/// 차트를 표현할 수 있는 view
open class ChartERView: UIView {
    // 옵션
    /// 메인 색상
    var mainColor: CGColor = CGColor(red: 36/255, green: 138/255, blue: 1, alpha: 1)
    /// 보조 색상
    var subColor: CGColor = CGColor(red: 36/255, green: 138/255, blue: 1, alpha: 1)
    /// 축 색상
    var axisColor: CGColor = CGColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    
    // 데이터
    /// 이름
    open var xAxisNames: [String] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    /// 값
    open var series: ChartERSeries = .empty {
        didSet {
            setNeedsLayout()
        }
    }
    /// 인덱스
    var currentIndex: Int = 0
    
    // 레이아웃
    /// 여백
    var chartInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    /// 크기
    var chartBound: CGRect {
        CGRect(x: chartInset.left, y: chartInset.top, width: frame.width - chartInset.left - chartInset.right, height: frame.height - chartInset.top - chartInset.bottom)
    }
    /// 애니메이션 시간
    var animateDuration: CFTimeInterval = 0.2
    
    // 레이어
    /// 원본 차트 레이어
    let seriesLayer: CAShapeLayer = CAShapeLayer()
    /// 차트 라벨
    var seriesLabels: [CATextLayer] = []
    /// 차트의 각 값을 특정 모양으로 찍는 레이어
    let markerLayer: CAShapeLayer = CAShapeLayer()
    /// 축 레이어
    let axisLayer: CAShapeLayer = CAShapeLayer()
    /// x축 라벨
    var xAxisLabels: [CATextLayer] = []
    /// y축 라벨
    var yAxisLabels: [CATextLayer] = []
    
    // 제스처
    private var oldTouch: CGPoint = .zero
    
    // 유틸리티
    /// 차트 Builder (default LineChartERBuilder)
    public var builder: ChartERBuilder = LineChartERBuilder() {
        didSet {
            seriesLayer.lineWidth = builder.seriesSize
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 축
        axisLayer.fillColor = nil
        axisLayer.strokeColor = axisColor
        axisLayer.lineWidth = 1
        layer.addSublayer(axisLayer)
        
        // 차트
        seriesLayer.fillColor = nil
        seriesLayer.strokeColor = mainColor
        seriesLayer.lineWidth = builder.seriesSize
        layer.addSublayer(seriesLayer)
        
        // 점
        markerLayer.fillColor = subColor
        markerLayer.strokeColor = UIColor.white.cgColor
        markerLayer.lineWidth = 2
        layer.addSublayer(markerLayer)
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(recognizer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        clearAxis()
        initializeAxis()
        
        updateChart()
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            oldTouch = recognizer.location(in: self)
            
        case .changed:
            let currentTouch = recognizer.location(in: self)
            let deltaTouch = CGPoint(x: currentTouch.x - oldTouch.x, y: currentTouch.y - oldTouch.y)
            if deltaTouch.x < -50 {
                indexScrollToNext()
                
                oldTouch = currentTouch
            } else if deltaTouch.x > 50 {
                indexScrollToPrev()
                
                oldTouch = currentTouch
            }
            
        default:
            break
        }
    }
    
    private func indexScrollToPrev() {
        guard currentIndex > 0 else {
            return
        }
        
        currentIndex -= 1
        
        updateChart()
    }
    
    private func indexScrollToNext() {
        guard currentIndex + builder.xAxisLabelCount < series.values.count else {
            return
        }
        
        currentIndex += 1
        
        updateChart()
    }
    
    private func clearAxis() {
        xAxisLabels.forEach { $0.removeFromSuperlayer() }
        xAxisLabels = []
        
        yAxisLabels.forEach { $0.removeFromSuperlayer() }
        yAxisLabels = []
    }
    
    private func initializeAxis() {
        // axis
        axisLayer.path = builder.axisPath(in: chartBound)
        
        // x axis label
        builder.xAxisLabelPoints(in: chartBound).forEach { point in
            let label = CATextLayer()
            label.frame = CGRect(x: point.x - 20, y: point.y + 5, width: 40, height: 20)
            label.foregroundColor = axisColor
            label.fontSize = 8
            label.contentsScale = UIScreen.main.scale
            label.alignmentMode = .center
            axisLayer.addSublayer(label)
            xAxisLabels.append(label)
        }
        
        // y axis label
        builder.yAxisLabelInfos(in: chartBound).forEach { point in
            let label = CATextLayer()
            label.frame = CGRect(x: point.x - 45, y: point.y - 10, width: 40, height: 20)
            label.foregroundColor = axisColor
            label.fontSize = 9
            label.contentsScale = UIScreen.main.scale
            label.alignmentMode = .right
            axisLayer.addSublayer(label)
            yAxisLabels.append(label)
        }
    }
    
    private func updateChart(animated: Bool = true) {
        print("update chart")
        
        builder.update(to: currentIndex, in: chartBound, with: series)
        
        updateXAxisLabel()
        updateYAxisLabel()
        updateSeries(animated: animated)
        
        // marker
        let markerPath = builder.markerPath()
        
        if animated {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = markerLayer.presentation()?.path ?? markerPath
            pathAnimation.toValue = markerPath
            pathAnimation.duration = animateDuration
            markerLayer.add(pathAnimation, forKey: "path")
        }
        
        markerLayer.path = markerPath
    }
    
    private func updateXAxisLabel() {
        for visibleIndex in 0 ..< xAxisLabels.count {
            if currentIndex + visibleIndex < xAxisNames.count - 1 {
                xAxisLabels[visibleIndex].string = xAxisNames[currentIndex + visibleIndex]
            } else {
                xAxisLabels[visibleIndex].string = "\(currentIndex + visibleIndex)"
            }
        }
    }
    
    private func updateYAxisLabel() {
        guard let min = series.values.min(),
              let max = series.values.max() else {
            return
        }
        
        for visibleIndex in 0 ..< yAxisLabels.count {
            let alpha = Float(visibleIndex) / Float(yAxisLabels.count - 1)
            let value = lerp(min, max, 1 - alpha)
            yAxisLabels[visibleIndex].string = "\(Int(value))"
        }
    }
    
    private func updateSeries(animated: Bool) {
        let seriesPath = builder.seriesPath(in: chartBound)
        
        if animated {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = seriesLayer.presentation()?.path ?? seriesPath
            pathAnimation.toValue = seriesPath
            pathAnimation.duration = animateDuration
            seriesLayer.add(pathAnimation, forKey: "path")
        }
        
        seriesLayer.path = seriesPath
    }
}
