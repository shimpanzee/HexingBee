//
//  ScoreView.swift
//
//  Visualization of the score on a rank ladder
//

import UIKit

class ScoreView: UIView {
    private var score = 0
    private var rank = Rank.beginner

    private var y: CGFloat = 0.0

    private let label = UILabel()

    private let segCount = 8
    private let segLength: CGFloat = 30
    private let padding: CGFloat = 15.0

    private var circles = [CAShapeLayer]()
    private var rankCircle = CAShapeLayer()

    init() {
        let width = padding * CGFloat(2.0) + segLength * CGFloat(segCount)
        super.init(frame: CGRectMake(0, 0, width, 40))

        y = frame.height / 2

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        widthAnchor.constraint(equalToConstant: frame.width).isActive = true

        buildLine(start: padding, end: padding+segLength*CGFloat(segCount), color: UIColor.Bee.ladder.cgColor)

        buildCircles()

        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center

        // Size the label up front.  It will make animations
        // easier if the size of the label doesn't change.
        // Use arbitrary string with max number of digits.
        label.text = "000"
        label.sizeToFit()

        addSubview(label)
        configureLabel()
        label.center = CGPoint(x: padding, y: y)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buildCircles() {
        for circle in circles {
            circle.removeFromSuperlayer()
        }
        circles.removeAll()

        for i in 0...segCount {
            buildCircle(x: padding+CGFloat(i)*segLength)
        }

        configureCircleColors()

        buildCircle(x: padding, isRankCircle: true)

    }

    func configureCircleColors() {
        for i in 0...segCount {
            let color = i > rank.rawValue ? UIColor.Bee.ladder.cgColor : UIColor.Bee.ladderHighlight.cgColor
            circles[i].fillColor = color
            circles[i].strokeColor = color
        }

    }

    func update(score: Int, rank: Rank) {
        self.score = score
        let oldRank = self.rank
        self.rank = rank
        configureLabel()
        configureCircleColors()

        if rank != .queen_bee {
            updateRankDisplay(from: oldRank, to: rank)
        }
    }

    private func updateRankDisplay(from: Rank, to: Rank) {
        // Animate the score and the containing circle to the new
        // location on the rank ladder
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut))

        let delta = segLength*CGFloat(to.rawValue - from.rawValue)

        let circleAnimation = CABasicAnimation(keyPath: "position.x")
        circleAnimation.fromValue = rankCircle.position.x
        rankCircle.position.x += delta
        circleAnimation.toValue = rankCircle.position.x

        rankCircle.add(circleAnimation, forKey: "animateCircle")

        let textAnimation = CABasicAnimation(keyPath: "position")
        textAnimation.fromValue = NSValue(cgPoint: label.center)
        let newCenter = CGPointMake(label.center.x+delta, label.center.y)
        textAnimation.toValue = NSValue(cgPoint: newCenter)

        label.center = newCenter

        label.layer.add(textAnimation, forKey: "animateLabel")
        CATransaction.commit()
    }

    private func configureLabel() {
        label.text = "\(score)"
    }

    private func buildLine(start: CGFloat, end: CGFloat, color: CGColor) {

        let scoredLinePath = UIBezierPath()

        scoredLinePath.lineWidth=2
        scoredLinePath.move(to: CGPoint(x: start, y: y))

        scoredLinePath.addLine(to: CGPoint(x: end, y: y))

        scoredLinePath.close()

        let scoreLineLayer = CAShapeLayer()
        scoreLineLayer.strokeColor=color
        scoreLineLayer.path = scoredLinePath.cgPath
        scoreLineLayer.zPosition = -1

        layer.addSublayer(scoreLineLayer)
    }

    private func buildCircle(x: CGFloat, isRankCircle: Bool = false) {
        let circlePath = UIBezierPath()
        let radius: CGFloat = isRankCircle ? 12 : 3
        circlePath.addArc(withCenter: CGPoint(x: x, y: y), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2.0, clockwise: true)
        let circleLayer = CAShapeLayer()

        let color = isRankCircle ? UIColor.Bee.ladderHighlight.cgColor : UIColor.Bee.ladder.cgColor

        circleLayer.strokeColor = color
        circleLayer.fillColor = color
        circleLayer.path = circlePath.cgPath
        circleLayer.zPosition = -1

        layer.addSublayer(circleLayer)
        if isRankCircle {
            rankCircle = circleLayer
        } else {
            circles.append(circleLayer)
        }
    }

}
