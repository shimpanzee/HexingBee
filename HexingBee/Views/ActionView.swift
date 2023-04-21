//
//  ActionView.swift
//
//  Delete/Shuffle/Enter toolbar below puzzle
//

import TinyConstraints
import UIKit

protocol ActionViewDelegate: AnyObject {
    func scramblePuzzlePressed()
    func submitWordPressed()
    func deleteLetterPressed()
}

class ActionView: UIView {
    weak var delegate: ActionViewDelegate?

    init() {
        super.init(frame: .zero)

        let shuffleButton = UIButton()
        shuffleButton.setImage(UIImage(named: "shuffle"), for: .normal)
        let shuffleDiameter: CGFloat = 34
        shuffleButton.size(CGSize(width: shuffleDiameter, height: shuffleDiameter))
        shuffleButton.layer.borderColor = UIColor.gray.cgColor
        shuffleButton.layer.borderWidth = 0.3
        shuffleButton.layer.cornerRadius = shuffleDiameter / 2
        shuffleButton.layer.cornerCurve = .continuous
        let shuffleInset: CGFloat = 5.0
        shuffleButton.contentEdgeInsets = UIEdgeInsets(top: shuffleInset, left: shuffleInset, bottom: shuffleInset, right: shuffleInset)

        self.addSubview(shuffleButton)
        shuffleButton.centerInSuperview()

        shuffleButton.addTarget(self, action: #selector(scramble), for: .touchUpInside)

        let interButtonPadding: CGFloat = 20.0

        func configure(button: UIButton) {
            button.centerY(to: shuffleButton)
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.borderWidth = 0.3
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)

            button.layer.cornerRadius = button.intrinsicContentSize.height / 2
            button.layer.cornerCurve = .continuous

            button.setCompressionResistance(.required, for: .vertical)
        }

        let deleteButton = UIButton(type: .custom)
        deleteButton.setTitle("Delete", for: .normal)
        self.addSubview(deleteButton)
        deleteButton.rightToLeft(of: shuffleButton, offset: -interButtonPadding)
        deleteButton.addTarget(self, action: #selector(self.deleteLetter), for: .touchUpInside)
        configure(button: deleteButton)

        let submitButton = UIButton(type: .custom)
        submitButton.setTitle("Enter", for: .normal)
        self.addSubview(submitButton)
        submitButton.leftToRight(of: shuffleButton, offset: interButtonPadding)
        submitButton.width(to: deleteButton)
        submitButton.addTarget(self, action: #selector(self.submitWord), for: .touchUpInside)
        configure(button: submitButton)

        self.height(to: shuffleButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func scramble() {
        delegate?.scramblePuzzlePressed()
    }

    @objc func submitWord() {
        delegate?.submitWordPressed()
    }

    @objc func deleteLetter() {
        delegate?.deleteLetterPressed()
    }
    
}
