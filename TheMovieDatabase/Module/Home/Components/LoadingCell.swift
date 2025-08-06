//
//  LoadingCell.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 05/08/25.
//

import UIKit

class LoadingCell: UITableViewCell {
    static let identifier = "LoadingCell"
    
    let spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        spinner.startAnimating()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
