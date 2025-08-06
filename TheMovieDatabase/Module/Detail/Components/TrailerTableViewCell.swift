//
//  TrailerTableViewCell.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import UIKit
import WebKit

class TrailerTableViewCell: UITableViewCell {
    
    static let identifier = "TrailerTableViewCell"
    
    @IBOutlet weak var webVideoPlayer: WKWebView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        webVideoPlayer.configuration.mediaTypesRequiringUserActionForPlayback = []
        initialUISetup()
    }
    
    private func initialUISetup() {
        self.contentView.backgroundColor = .systemBackground
    }
    
    func configure(trailerUrlKey: String?, posterUrl: String) {
        if let key = trailerUrlKey {
            webVideoPlayer.isHidden = false
            posterImageView.isHidden = true
            callVideoUrl(key: key)
        } else {
            webVideoPlayer.isHidden = true
            posterImageView.isHidden = false
            addImage(path: posterUrl)
        }
    }
    
    private func callVideoUrl(key: String) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(key)") else {
            return
        }
        DispatchQueue.main.async {
            if !key.isEmpty {
                self.webVideoPlayer.load(URLRequest(url: url))
            }
        }
    }
    
    private func addImage(path: String) {
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
        DispatchQueue.main.async {
            if !path.isEmpty {
                self.posterImageView.setImage(with: url)
            }
        }
    }
}
