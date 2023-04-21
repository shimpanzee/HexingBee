//
//  Congratulator.swift
//
//  Animation to show score updates
//

import UIKit

extension UIView {

    func animateCongratulations(message: String, delta: Int, center: CGPoint) {
        let congratsLabel = UILabel()
        congratsLabel.text = "\(message) +\(delta)"
        congratsLabel.sizeToFit()
        congratsLabel.center = center
        congratsLabel.layer.borderColor = UIColor.lightGray.cgColor
        congratsLabel.layer.borderWidth = 1
        addSubview(congratsLabel)
        UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 3/4) {
                congratsLabel.center.y -= 90
            }
            UIView.addKeyframe(withRelativeStartTime: 3/4, relativeDuration: 1/4) {
                congratsLabel.layer.opacity = 0
            }
        }) { _ in
            congratsLabel.removeFromSuperview()
        }
    }
    
}
