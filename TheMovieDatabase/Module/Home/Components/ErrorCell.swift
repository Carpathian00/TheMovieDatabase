//
//  ErrorCell.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 05/08/25.
//

import UIKit

class ErrorCell: UITableViewCell {
    
    static let identifier = "ErrorCell"
    
    // MARK: - UI Components
    let logoImageView = UIImageView()
    let titleLabel = UILabel()
    let retryButton = UIButton(type: .system)

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    private func setupViews() {
        // Logo
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .systemRed

        // Title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label

        // Retry Button
        var config = UIButton.Configuration.filled()
        config.title = "Retry"
        config.baseBackgroundColor = .systemGray6
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
        retryButton.configuration = config
        retryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        retryButton.backgroundColor = UIColor.systemGray6
        retryButton.layer.cornerRadius = 8

        // Add subviews
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(retryButton)
    }

    private func layoutViews() {
        // Use Auto Layout
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            logoImageView.widthAnchor.constraint(equalToConstant: 48),
            logoImageView.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            retryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    // MARK: - Configure
    func configure(logo: UIImage?, title: String, buttonTitle: String = "Retry") {
        logoImageView.image = logo
        titleLabel.text = title
        retryButton.setTitle(buttonTitle, for: .normal)
    }
}

