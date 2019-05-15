//
//  PerformanceHUDView.swift
//  yologle
//
//  Created by d. nye on 5/14/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class PerformanceHUDView: UIView {

    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!

    var index: Int = -1
    var measurements: [Dictionary<String, Double>]? = nil

    override func awakeFromNib() {
        inferenceLabel.text = "inference:"
        etimeLabel.text = "execution:"
        fpsLabel.text = "fps:"
        
        let measurement = [
            "start": CACurrentMediaTime(),
            "end": CACurrentMediaTime()
        ]
        measurements = Array<Dictionary<String, Double>>(repeating: measurement, count: 30)

    }
    
    public func start() {
        index += 1
        index %= 30
        measurements?[index] = [:]
        
        addLabel(for: index, with: "start")

    }
    
    public func stop() {
        addLabel(for: index, with: "end")
        
        if let beforeMeasurement = getBeforeMeasurment(for: index),
            let currentMeasurement = measurements?[index],
            let startTime = currentMeasurement["start"],
            let endInferenceTime = currentMeasurement["endInference"],
            let endTime = currentMeasurement["end"],
            let beforeStartTime = beforeMeasurement["start"] {
                
                updateMeasure(inferenceTime: endInferenceTime - startTime,
                                        executionTime: endTime - startTime,
                                        fps: Int(1/(startTime - beforeStartTime)))
            }
    }

    public func label(with msg: String? = "") {
        addLabel(for: index, with: msg)
    }

    private func addLabel(for index: Int, with msg: String? = "") {
        if let message = msg {
            measurements?[index][message] = CACurrentMediaTime()
        }
    }
    
    private func getBeforeMeasurment(for index: Int) -> Dictionary<String, Double>? {
        return measurements?[(index + 30 - 1) % 30]
    }

    private func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        self.inferenceLabel.text = "inference: \(Int(inferenceTime*1000.0)) ms"
        self.etimeLabel.text = "execution: \(Int(executionTime*1000.0)) ms"
        self.fpsLabel.text = "fps: \(fps)"

    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
