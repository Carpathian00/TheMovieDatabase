//
//  MovieDetailTableViewCell.swift
//  NetflixClone
//
//  Created by Adlan Nourindiaz on 12/04/23.
//

import UIKit
import WebKit

class MovieDetailTableViewCell: UITableViewCell {
    
    static let identifier = "MovieDetailTableViewCell"

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemGenres: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var optionButtonStackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        optionButtonStackView.isHidden = true
    }

    func configureByMovie(detailModel: MovieDetail?) {
        self.itemTitle.text = detailModel?.originalTitle
        
        if let genreNames = detailModel?.genres?.compactMap({ $0.name }), !genreNames.isEmpty {
        self.itemGenres.text = genreNames.joined(separator: ", ")
        } else {
        self.itemGenres.text = "Unknown"
        }

        self.releaseDate.text = "Release Year: " + (detailModel?.releaseYear ?? "Unknown")
        
        self.overview.text = detailModel?.overview
        
        if let voteAverage = detailModel?.voteAverage {
            addScoreBar(voteAverage: voteAverage)
        }
    }
   
    func configureByTv(detailModel: TVDetail?) {
        self.itemTitle.text = detailModel?.originalName
        
        if let genreNames = detailModel?.genres?.compactMap({ $0.name }), !genreNames.isEmpty {
        self.itemGenres.text = genreNames.joined(separator: ", ")
        } else {
        self.itemGenres.text = "Unknown"
        }
        self.releaseDate.text = "Last Air Date: " + (detailModel?.formattedLastAirDate ?? "Unknown")
        
        self.overview.text = detailModel?.overview
        
        if let voteAverage = detailModel?.voteAverage {
            addScoreBar(voteAverage: voteAverage)
        }

    }

    private func addScoreBar(voteAverage: Double?) {
        let scoreBar = CircularScoreBar(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        scoreBar.percentage = (voteAverage ?? 0) / 10
        contentView.addSubview(scoreBar)

        scoreBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            scoreBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            scoreBar.leadingAnchor.constraint(equalTo: itemTitle.trailingAnchor, constant: 8),
            scoreBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            scoreBar.heightAnchor.constraint(equalToConstant: 75),
            scoreBar.widthAnchor.constraint(equalToConstant: 75),
            itemGenres.trailingAnchor.constraint(equalTo: scoreBar.leadingAnchor, constant: -8)
        ])
    }
}
