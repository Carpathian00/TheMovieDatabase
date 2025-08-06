//
//  LoadMoreCell.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import UIKit

class LoadMoreReviewCell: UITableViewCell {
    
    static let identifier = "LoadMoreReviewCell"
    
    let loadMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load More", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onTapLoadMore: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        contentView.addSubview(loadMoreButton)
        NSLayoutConstraint.activate([
            loadMoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadMoreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            loadMoreButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            loadMoreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        loadMoreButton.addTarget(self, action: #selector(loadMoreTapped), for: .touchUpInside)
    }
    
    @objc private func loadMoreTapped() {
        onTapLoadMore?()
    }
}
