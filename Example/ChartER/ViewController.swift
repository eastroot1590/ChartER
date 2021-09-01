//
//  ViewController.swift
//  ChartER
//
//  Created by eastroot1590@gmail.com on 08/30/2021.
//  Copyright (c) 2021 eastroot1590@gmail.com. All rights reserved.
//

import UIKit
import ChartER

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let chart = ChartERView(frame: CGRect(origin: CGPoint(x: 0, y: 100), size: CGSize(width: view.frame.width, height: 200)))
//        chart.builder = LineChartERBuilder(visibleValuesCount: 7)
        chart.builder = BarChartERBuilder(visibleValuesCount: 5)
        chart.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        chart.series = ChartERSeries(name: "hello", values: [13, 5, 7, 2, -4, 15, -21, -21, -21, 1, 5, 17])
        chart.xAxisNames = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월"]
        view.addSubview(chart)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

