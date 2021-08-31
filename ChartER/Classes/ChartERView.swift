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
    /// 표시할 값 개수
    var visibleValuesCount: Int = 7
    /// 각 점들 사이의 최소 거리
    var minimumSpacing: CGFloat = 20
    /// 포인트 점 보기 감추기
    public var showsPointDots: Bool = true {
        didSet {
            if showsPointDots {
                layer.addSublayer(pointLayer)
            } else {
                pointLayer.removeFromSuperlayer()
            }
        }
    }
    
    // 데이터
    /// 이름
    var names: [String] = []
    /// 값
    var series: ChartERSeries = .empty {
        didSet {
            guard series.values.count > 0 else {
                return
            }
            
            self.minValue = series.values.min() ?? 0
            self.maxValue = series.values.max() ?? 0
        }
    }
    var minValue: Float = 0
    var maxValue: Float = 0
    /// 현재 가장 좌측 인덱스
    var currentIndex: Int = 0
    
    // 레이아웃
    /// 크기
    var chartSize: CGSize {
        let width = frame.width - chartInset.left - chartInset.right - axisSize.width
        let height = frame.height - chartInset.top - chartInset.bottom - axisSize.height
        
        return CGSize(width: width, height: height)
    }
    /// 여백
    var chartInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    /// 축 여백
    var axisSize: CGSize = CGSize(width: 50, height: 50)
    /// 애니메이션 시간
    var animateDuration: CFTimeInterval = 0.2
    /// 각 점들 사이의 거리
    var spacing: CGFloat {
        return max(chartSize.width / CGFloat(visibleValuesCount - 1), minimumSpacing)
    }
    
    // 레이어
    /// 원본 차트 레이어
    let chartLayer: CAShapeLayer = CAShapeLayer()
    /// 차트의 각 값을 특정 모양으로 찍는 레이어
    let pointLayer: CAShapeLayer = CAShapeLayer()
    /// 축 레이어
    let axisLayer: CAShapeLayer = CAShapeLayer()
    /// x축 라벨
    var xAxisLabels: [CATextLayer] = []
    /// y축 라벨
    var yAxisLabels: [CATextLayer] = []
    
    // 제스처
    private var oldTouch: CGPoint = .zero
    
    // 유틸리티
    public var builder: ChartERBuilder! {
        didSet {
            oldValue?.chart = nil
            builder?.chart = self
            
            chartLayer.lineWidth = builder.chartSize
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // default builder
        builder = LineChartERBuilder()
        
        // 축
        axisLayer.fillColor = nil
        axisLayer.strokeColor = axisColor
        axisLayer.lineWidth = 1
        layer.addSublayer(axisLayer)
        
        // 차트
        chartLayer.fillColor = nil
        chartLayer.strokeColor = mainColor
        chartLayer.lineWidth = builder.chartSize
        layer.addSublayer(chartLayer)
        
        // 점
        pointLayer.fillColor = subColor
        pointLayer.strokeColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        pointLayer.lineWidth = 2
        layer.addSublayer(pointLayer)
        
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(recognizer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        chartLayer.frame = bounds
        axisLayer.frame = bounds
        
        // update appearance
        updateChart()
        updateAxis()
    }
    
    open func addSets(_ series: ChartERSeries) {
        self.series = series
        
        resetAxis()
    }
    
    open func setName(_ names: [String]) {
        self.names = names
        
        resetAxis()
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            oldTouch = recognizer.location(in: self)
            
        case .changed:
            let currentTouch = recognizer.location(in: self)
            let deltaTouch = CGPoint(x: currentTouch.x - oldTouch.x, y: currentTouch.y - oldTouch.y)
            if deltaTouch.x < -spacing {
                indexScrollToNext()
                
                oldTouch = currentTouch
            } else if deltaTouch.x > spacing {
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
        setNeedsLayout()
    }
    
    private func indexScrollToNext() {
        guard currentIndex + visibleValuesCount < series.values.count else {
            return
        }
        
        currentIndex += 1
        setNeedsLayout()
    }
    
    private func updateChart(animated: Bool = true) {
        let linePath = builder.chartPath(at: currentIndex)
        let pointPath = builder.pointPath(at: currentIndex)
        
        if animated {
            let chartAnimation = CABasicAnimation(keyPath: "path")
            chartAnimation.fromValue = chartLayer.path ?? linePath
            chartAnimation.toValue = linePath
            chartAnimation.duration = animateDuration
            chartAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            chartLayer.removeAnimation(forKey: "path")
            chartLayer.add(chartAnimation, forKey: "path")
            
            let pointAnimation = CABasicAnimation(keyPath: "path")
            pointAnimation.fromValue = pointLayer.path ?? pointPath
            pointAnimation.toValue = pointPath
            pointAnimation.duration = animateDuration
            pointAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            pointLayer.removeAnimation(forKey: "path")
            pointLayer.add(pointAnimation, forKey: "path")
        }
        
        chartLayer.path = linePath
        pointLayer.path = pointPath
    }
    
    private func resetAxis() {
        // axis
        axisLayer.path = builder?.axis()
        
        // x axis label
        xAxisLabels.forEach { $0.removeFromSuperlayer() }
        xAxisLabels = builder?.xAxisLabels() ?? []
        xAxisLabels.forEach { self.layer.addSublayer($0) }
        
        // y axis label
        yAxisLabels.forEach { $0.removeFromSuperlayer() }
        yAxisLabels = builder?.yAxisLabels() ?? []
        yAxisLabels.forEach { self.layer.addSublayer($0) }
    }
    
    private func updateAxis() {
        for i in 0 ..< xAxisLabels.count {
            var labelString: String
            
            if currentIndex + i < names.count {
                labelString = names[currentIndex + i]
            } else {
                labelString = "\(currentIndex + i)"
            }

            // 이걸 왜 해줘야하는지 모르겠다. 안하면 updateChart 애니메이션을 씹어버린다.
            let animation = CABasicAnimation(keyPath: "string")
            animation.fromValue = labelString
            animation.toValue = labelString
            animation.duration = animateDuration
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            xAxisLabels[i].removeAnimation(forKey: "string")
            xAxisLabels[i].add(animation, forKey: "string")
        }
    }
}
