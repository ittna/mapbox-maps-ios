//
//  AnimatedAnnotationView.swift
//  Examples
//
//  Created by Antti Ahvenlampi on 24.2.2024.
//

import UIKit
import QuartzCore

private struct MapPinPoints {
    let radius: CGFloat
    let iconCenter: CGPoint
    let bottomCenter: CGPoint
    let curve1ControlPoints: (CGPoint, CGPoint)
    let curve2ControlPoints: (CGPoint, CGPoint)

    var path: CGPath {
        let path = UIBezierPath()
        path.move(to: bottomCenter)
        path.addCurve(to: CGPoint(x: iconCenter.x + radius, y: iconCenter.y), controlPoint1: curve1ControlPoints.0, controlPoint2: curve1ControlPoints.1)
        path.addArc(withCenter: iconCenter, radius: radius, startAngle: 0, endAngle: .pi, clockwise: false)
        path.addCurve(to: bottomCenter, controlPoint1: curve2ControlPoints.0, controlPoint2: curve2ControlPoints.1)
        return path.cgPath
    }

}

private let circlePoints = MapPinPoints(radius: 12, iconCenter: CGPoint(x: 16, y: 45), bottomCenter: CGPoint(x: 16, y: 57), curve1ControlPoints: (CGPoint(x: 22.667, y: 57), CGPoint(x: 28, y: 51.667)), curve2ControlPoints: (CGPoint(x: 4, y: 51.667), CGPoint(x: 9.333, y: 57)))

final class AnimatedAnnotationView: UIView {

    static let size = CGSize(width: 32, height: 60)

    private var iconView: UIImageView!
    
    private var iconTopConstraint: NSLayoutConstraint!
    private var iconHeightConstraint: NSLayoutConstraint!

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    private func commonInit() {
        layer.lineWidth = 2
        layer.fillColor = UIColor.blue.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.3

        let iconView = UIImageView(frame: .zero)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = .checkmark
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .red
        addSubview(iconView)
        self.iconView = iconView
        
        let pinGuide = UILayoutGuide()
        addLayoutGuide(pinGuide)
        
        let iconGuide = UILayoutGuide()
        addLayoutGuide(iconGuide)
        
        iconTopConstraint = iconGuide.topAnchor.constraint(equalTo: pinGuide.topAnchor, constant: 39)
        iconHeightConstraint = iconGuide.heightAnchor.constraint(equalToConstant: 12)

        NSLayoutConstraint.activate([
            pinGuide.topAnchor.constraint(equalTo: topAnchor),
            pinGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            pinGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            pinGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            iconGuide.centerXAnchor.constraint(equalTo: pinGuide.centerXAnchor),
            iconGuide.widthAnchor.constraint(equalTo: iconGuide.heightAnchor),
            iconTopConstraint,
            iconHeightConstraint,

            iconView.topAnchor.constraint(equalTo: iconGuide.topAnchor),
            iconView.bottomAnchor.constraint(equalTo: iconGuide.bottomAnchor),
            iconView.leadingAnchor.constraint(equalTo: iconGuide.leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: iconGuide.trailingAnchor),
        ])
        
        updatePinState()
    }
    
    private func updatePinState() {
        layer.path = circlePoints.path
        layer.shadowPath = circlePoints.path
        
        iconTopConstraint.constant = 39
        iconHeightConstraint.constant = 12
        
        layoutIfNeeded()
    }
}

