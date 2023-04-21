//
//  RootViewController.swift
//

import Combine
import TinyConstraints
import UIKit

class RootViewController: UIViewController {

    private let wordInputView = UITextField()
    private let errorView = UIView()
    private let hiveView = HiveView()
    private let inputSectionView = UIStackView()
    private let horizontalStackView = UIStackView()
    private let verticalStackView = UIStackView()
    private let answersView = UIView()
    private var actionView = ActionView()
    private let puzzleView = UIView()
    private let rankScoreView = UIView()
    private var compactConstraints = [Constraint]()
    private var regularConstraints = [Constraint]()

    private let viewModel: HexingBeeViewModel

    private var subscriptions = Set<AnyCancellable>()

    init(viewModel: HexingBeeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        configureVerticalStack()
        configureScoreView()
        configureInputView(inputSectionView)
        configureErrorView()
        configurePuzzleView(puzzleView)
        configureAnswersView()
        configureActionView()
        configureCongratulator()
        configureForConstraints()

        viewModel.$bee
            .sink { [weak self] _ in
                self?.viewModel.resetGame()
            }
            .store(in: &subscriptions)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        configureForConstraints()
    }
}

extension RootViewController {
    func configureForConstraints() {
        let toDisable = traitCollection.verticalSizeClass == .regular ? compactConstraints : regularConstraints

        for constraint in toDisable { constraint.isActive = false }

        answersView.removeFromSuperview()
        if traitCollection.verticalSizeClass == .compact {
            verticalStackView.removeArrangedSubview(answersView)
            view.addSubview(answersView)
        } else {
            verticalStackView.addArrangedSubview(answersView)
        }

        let toEnable = traitCollection.verticalSizeClass == .compact ? compactConstraints : regularConstraints

        for constraint in toEnable { constraint.isActive = true }

        view.setNeedsUpdateConstraints()
    }

    func configureVerticalStack() {
        let safeArea = view.safeAreaLayoutGuide

        verticalStackView.axis = .vertical
        view.addSubview(verticalStackView)
        verticalStackView.edges(to: safeArea, excluding: .right)

        verticalStackView.addArrangedSubview(rankScoreView)
        verticalStackView.addArrangedSubview(errorView)
        verticalStackView.addArrangedSubview(inputSectionView)
        verticalStackView.addArrangedSubview(puzzleView)
        verticalStackView.addArrangedSubview(actionView)

        compactConstraints.append(verticalStackView.width(to: safeArea, multiplier: 0.55))
        regularConstraints.append(verticalStackView.width(to: safeArea))
    }

    func animateCongratulations(message: String, delta: Int) {
        let center = inputSectionView.convert(wordInputView.center, to: view)
        view.animateCongratulations(message: message, delta: delta, center: center)
    }

    func configureCongratulator() {
        viewModel.congrats
            .sink { [weak self] (message, delta) in
                self?.animateCongratulations(message: message, delta: delta)
            }
            .store(in: &subscriptions)
    }

    func configureScoreView() {
        let rankLabel = UILabel()
        rankScoreView.addSubview(rankLabel)
        rankLabel.centerYToSuperview()
        rankLabel.leading(to: rankScoreView, offset: 20)

        let scoreView = ScoreView()
        rankScoreView.addSubview(scoreView)
        scoreView.centerYToSuperview()
        scoreView.leadingToTrailing(of: rankLabel, offset: 10)
        scoreView.rightToSuperview()

        scoreView.topToSuperview()
        scoreView.bottomToSuperview()

        viewModel.$score
            .sink { [weak self, weak scoreView] score in
                if let self = self, let scoreView = scoreView {
                    scoreView.update(score: score, rank: self.viewModel.rank)
                }
            }
            .store(in: &subscriptions)

        viewModel.$rank
            .sink { [weak rankLabel] rank in
                rankLabel?.text = rank.string()
            }
            .store(in: &subscriptions)
    }

    func configureErrorView() {
        errorView.height(30)

        let errorLabel = UILabel()
        errorView.addSubview(errorLabel)
        errorLabel.centerInSuperview()

        viewModel.$errorMessage
            .sink { [weak errorLabel] errorMessage in
                if let errorLabel = errorLabel {
                    errorLabel.text = errorMessage
                    if errorMessage != nil {
                        errorLabel.textColor = .label
                    } else {
                        errorLabel.textColor = .systemBackground
                    }
                }
            }
            .store(in: &subscriptions)
    }

    func configureAnswersView() {
        let resultsGrid = FoundWordsViewController(viewModel: viewModel)
        addChild(resultsGrid)
        answersView.addSubview(resultsGrid.view)

        resultsGrid.view.edgesToSuperview(insets: UIEdgeInsets(top: 20, left: 5, bottom: 0, right: 5), priority: .defaultLow)

        view.addSubview(answersView)

        let safeArea = view.safeAreaLayoutGuide
        compactConstraints.append(contentsOf: [
            answersView.topToBottom(of: rankScoreView),
            answersView.height(to: verticalStackView),
            answersView.leftToRight(of: verticalStackView),
            answersView.right(to: safeArea)
        ])
    }

    func configurePuzzleView(_ puzzleView: UIView) {
        hiveView.delegate = self

        puzzleView.addSubview(hiveView)

        hiveView.centerXToSuperview()

        hiveView.edgesToSuperview(excluding: [.left, .right], insets: .uniform(15))

        let spinner = UIActivityIndicatorView(style: .large)
        puzzleView.addSubview(spinner)
        spinner.startAnimating()
        spinner.centerInSuperview()
        spinner.hidesWhenStopped = true

        viewModel.$bee
            .sink { [weak hiveView] bee in
                if let hiveView = hiveView, let bee = bee {
                    spinner.stopAnimating()

                    hiveView.updateLetters(innerLetter: bee.centerLetter,
                                           outerLetters: bee.outerLetters)
                }
            }
            .store(in: &subscriptions)
    }

    func configureActionView() {
        actionView.delegate = self
        actionView.centerX(to: puzzleView)
    }
    
    func configureInputView(_ inputSectionView: UIStackView) {
        inputSectionView.accessibilityIdentifier = "inputSectionView"
        let leftPadding = UIView()
        leftPadding.accessibilityIdentifier = "leftPadding"
        inputSectionView.addArrangedSubview(leftPadding)
        leftPadding.width(20)

        inputSectionView.addArrangedSubview(wordInputView)
        wordInputView.placeholder = "Enter word"
        wordInputView.borderStyle = .roundedRect
        wordInputView.autocapitalizationType = .none
        wordInputView.autocorrectionType = .no
        wordInputView.becomeFirstResponder()
        wordInputView.accessibilityIdentifier = "wordInputView"
        wordInputView.delegate = self
        wordInputView.centerX(to:puzzleView)

        let rightPadding = UIView()
        rightPadding.accessibilityIdentifier = "rightPadding"
        inputSectionView.addArrangedSubview(rightPadding)
        rightPadding.width(20)

        inputSectionView.height(wordInputView.intrinsicContentSize.height)
    }

    func submitWord() {
        if let text = wordInputView.text {
            viewModel.add(word: text)
        }
        wordInputView.text = ""
    }
}

extension RootViewController: ActionViewDelegate {
    func scramblePuzzlePressed() {
        hiveView.scramble()
    }

    func submitWordPressed() {
        submitWord()
    }

    func deleteLetterPressed() {
        if let currentText = wordInputView.text {
            wordInputView.text = String(currentText.dropLast())
        }
    }
}

extension RootViewController: HexDelegate {
    func cellClicked(letter: String) {
        wordInputView.text = (wordInputView.text ?? "") + letter.lowercased()
    }
}

extension RootViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitWord()
        return true
    }
}
