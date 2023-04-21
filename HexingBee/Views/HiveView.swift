//
//  HiveView.swift
//
//  Main puzzle view
//

import UIKit


protocol HexDelegate: AnyObject {
    func cellClicked(letter: String)
}

class HiveView: UIView, HexDelegate {

    weak var delegate: HexDelegate?

    private var centerHex = HexagonView(isCenter: true)
    private var topHex = HexagonView()
    private var bottomHex = HexagonView()
    private var nwHex = HexagonView()
    private var swHex = HexagonView()
    private var neHex = HexagonView()
    private var seHex = HexagonView()
    private var outerLetters = [String]()
    private let hexagonHeight: CGFloat
    private let hexagonWidth: CGFloat

    override var intrinsicContentSize: CGSize {
        CGSizeMake(hexagonWidth, hexagonHeight)
    }

    init() {
        let padding = CGFloat(5)
        hexagonHeight = centerHex.frame.height*3+padding*2-centerHex.distanceToTop*6
        hexagonWidth = centerHex.frame.width*3+padding*2-centerHex.xShift*2

        super.init(frame: .zero)

        var constraints = [NSLayoutConstraint]()
        let view = self

        view.addSubview(centerHex)
        centerHex.delegate = self
        centerHex.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(centerHex.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(centerHex.centerYAnchor.constraint(equalTo: view.centerYAnchor))

        view.width(hexagonWidth)

        let verticalTranslate = centerHex.frame.height - centerHex.distanceToTop*2 + padding
        let horizontalTranslate = centerHex.frame.width / 2 + centerHex.xShift + padding
        let sideVerticalTranslate = centerHex.frame.height / 2 - centerHex.distanceToTop + padding/2

        view.addSubview(topHex)
        topHex.delegate = self
        topHex.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(topHex.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(topHex.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -verticalTranslate))

        view.addSubview(bottomHex)
        bottomHex.delegate = self
        bottomHex.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(bottomHex.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(bottomHex.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: verticalTranslate))

        view.addSubview(nwHex)
        nwHex.delegate = self
        nwHex.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(nwHex.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -horizontalTranslate))
        constraints.append(nwHex.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -sideVerticalTranslate))

        view.addSubview(swHex)
        swHex.delegate = self
        swHex.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(swHex.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -horizontalTranslate))
        constraints.append(swHex.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: sideVerticalTranslate))

        view.addSubview(neHex)
        neHex.delegate = self
        neHex.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(neHex.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: horizontalTranslate))
        constraints.append(neHex.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -sideVerticalTranslate))

        view.addSubview(seHex)
        seHex.delegate = self
        seHex.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(seHex.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: horizontalTranslate))
        constraints.append(seHex.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: sideVerticalTranslate))

        NSLayoutConstraint.activate(constraints)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Check if any of the subhexagons contain the point.  Make sure
        // to convert the touch location to the subview coordinates
        let result = subviews.contains(where: {
            !$0.isHidden
            && $0.isUserInteractionEnabled
            && $0.point(inside: self.convert(point, to: $0), with: event)
        })
        return result
    }

    func cellClicked(letter: String) {
        delegate?.cellClicked(letter: letter)
    }
}

extension HiveView {
    func updateLetters(innerLetter: String, outerLetters: [String]) {
        centerHex.letter = innerLetter.uppercased()

        self.outerLetters = outerLetters
        updateLetterDisplay()
    }

    func updateLetterDisplay() {
        topHex.letter = outerLetters[0].uppercased()
        bottomHex.letter = outerLetters[1].uppercased()
        nwHex.letter = outerLetters[2].uppercased()
        swHex.letter = outerLetters[3].uppercased()
        neHex.letter = outerLetters[4].uppercased()
        seHex.letter = outerLetters[5].uppercased()
    }

    func scramble() {
        outerLetters = outerLetters.shuffled()
        updateLetterDisplay()
    }

}
