//
//  FoundWordsViewController.swift
//
//

import UIKit
import Combine

class FoundWordsViewController: UICollectionViewController {

    private let viewModel: HexingBeeViewModel
    private var foundWords = [String]()

    private var subscriptions = Set<AnyCancellable>()

    init(viewModel: HexingBeeViewModel) {
        self.viewModel = viewModel

        let columnLayout = UICollectionViewFlowLayout()
        columnLayout.itemSize = CGSize(width: 120, height: 20)

        super.init(collectionViewLayout: columnLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.register(LabelCell.self, forCellWithReuseIdentifier: "Cell")

        viewModel.$foundWords
            .receive(on: DispatchQueue.main)
            .sink { foundWords in
                DispatchQueue.main.async { [weak self] in
                    self?.foundWords = foundWords.sorted()
                    self?.collectionView.reloadData()
                }
            }
            .store(in: &subscriptions)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.foundWords.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LabelCell
        cell.label.text = "\(foundWords[indexPath.row])"
        return cell
    }
}

class LabelCell: UICollectionViewCell {

    let label = UILabel()
    let underline = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.numberOfLines = 0
        contentView.addSubview(label)

        label.font = UIFont.systemFont(ofSize: 10)
        label.centerY(to: contentView)
        label.leading(to: contentView, offset: 5)

        underline.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        layer.addSublayer(underline)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let borderWidth: CGFloat = 1
        underline.frame = CGRectMake(0, self.frame.height - borderWidth, self.frame.width, borderWidth)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
