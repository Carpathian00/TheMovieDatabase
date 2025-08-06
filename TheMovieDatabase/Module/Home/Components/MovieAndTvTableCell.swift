//
//  MovieAndTvTableCell.swift
//  TheMovieDatabase
//
//  Created by Adlan Nourindiaz on 05/08/25.
//

import UIKit
import Nuke
import NukeUI

class MovieAndTvTableCell: UITableViewCell {

    static let identifier = "MovieAndTvTableCell"
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemRank: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView! {
        didSet {
            itemImage.contentMode = .scaleAspectFill
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            itemImage.widthAnchor.constraint(equalToConstant: 121),
            itemImage.heightAnchor.constraint(equalToConstant: 156),
        ])
    }

    func configure(itemModel: ItemData?, index: Int?) {
        guard let imagePath = itemModel?.posterPath else { return }
        
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(imagePath)")

        itemImage.setImage(with: url)

        if let index = index {
            itemRank.text = "#\(index)"
        }
        
        if itemModel?.originalTitle == nil {
            self.itemTitle.text = itemModel?.originalName
        } else {
            self.itemTitle.text = itemModel?.originalTitle
        }
        
        createScore(score: (itemModel?.voteAverage ?? 0))
    }
    
    private func createScore(score: Double) {
        let percentage: CGFloat = score
        scoreLabel.text = "Scores: \(Int(percentage * 10))%"
    }
}
