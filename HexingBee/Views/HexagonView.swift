//
//  HexagonView.swift
//
//  
//

import UIKit

class HexagonView: UIView {
    private(set) var distanceToTop: CGFloat = 0
    private(set) var xShift: CGFloat = 0
    private let hexagon = UIBezierPath()
    private let label = UILabel()
    var delegate: HexDelegate?

    var letter = "" {
        didSet {
            label.text = letter
            label.sizeToFit()
        }
    }

    init(isCenter: Bool = false) {
        super.init(frame: CGRectMake(0, 0, 80, 80))

        height(frame.height)
        width(frame.width)

        configHex(isCenter)
        configLabel()

        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.hexWasClicked))
        gesture.numberOfTapsRequired = 1
        addGestureRecognizer(gesture)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // ensure we only count clicks that are within the hexagon
        // bounds
        let result = hexagon.contains(point)
        return result
    }


    @objc func hexWasClicked(){
        delegate?.cellClicked(letter: letter)
    }
}

extension HexagonView {
    func configHex(_ isCenter: Bool) {
        let numberOfSides: CGFloat = 6
        let rectWidth: CGFloat = frame.width
        let radiusOuterCircle: CGFloat = rectWidth / 2
        let theta = (CGFloat.pi * 2) / numberOfSides

        func point(_ num: Int) -> CGPoint {
            let x = radiusOuterCircle * cos(2 * CGFloat.pi * CGFloat(num) / numberOfSides + theta)
            let y = radiusOuterCircle * sin(2 * CGFloat.pi * CGFloat(num) / numberOfSides + theta)
            return CGPoint(x: x, y: y)
        }

        let initialPoint = point(0)

        // keep track of some geometry details so that
        // the containing puzzle can more easily place the
        // individual hexes
        distanceToTop = radiusOuterCircle - initialPoint.y
        xShift = radiusOuterCircle - initialPoint.x

        hexagon.move(to: initialPoint)

        for i in 1...Int(numberOfSides) {
            hexagon.addLine(to: point(i))
        }

        // the affine transform is applied so the center of the hex is in
        // the center of the view frame
        hexagon.apply(CGAffineTransformMakeTranslation(radiusOuterCircle, radiusOuterCircle))
        hexagon.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = hexagon.cgPath;

        shapeLayer.fillColor = isCenter ? UIColor.Bee.innerHex.cgColor : UIColor.Bee.outerHex.cgColor
        shapeLayer.zPosition = -1

        layer.addSublayer(shapeLayer)
    }

    func configLabel() {
        label.text = letter
        addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.sizeToFit()
        label.centerInSuperview()
    }
}

