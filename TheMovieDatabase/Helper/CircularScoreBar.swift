//
//  CircularScoreBar.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import Foundation
import UIKit

class CircularScoreBar: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var percentageLabel = UILabel()
    
    var percentage: CGFloat = 0 {
        didSet {
            percentageLabel.text = "Scores: \(Int(percentage * 100))%"
            percentageLabel.numberOfLines = 0
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        let lineWidth = radius * 0.1
        
        // Draw track layer
        let trackPath = UIBezierPath(arcCenter: center, radius: radius - lineWidth/2, startAngle: -CGFloat.pi/2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = trackPath.cgPath
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        layer.addSublayer(trackLayer)
        
        // Draw progress layer
        let progressPath = UIBezierPath(arcCenter: center, radius: radius - lineWidth/2, startAngle: -CGFloat.pi/2, endAngle: 2 * CGFloat.pi * percentage - CGFloat.pi/2, clockwise: true)
        progressLayer.path = progressPath.cgPath
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = percentage < 0.5 ? UIColor.systemRed.cgColor : percentage < 0.75 ? UIColor.systemYellow.cgColor : UIColor.systemGreen.cgColor
        layer.addSublayer(progressLayer)
        
        // Add percentage label
        percentageLabel.frame = CGRect(x: 0, y: 0, width: radius*1.7, height: radius*1.7)
        percentageLabel.center = center
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.systemFont(ofSize: radius * 0.35, weight: .medium)
        addSubview(percentageLabel)
    }
    
}
