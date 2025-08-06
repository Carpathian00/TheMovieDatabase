//
//  ReviewTableViewCell.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import UIKit
import Foundation

protocol ReviewTableViewCellDelegate: AnyObject {
    func didTapReadMore(in cell: ReviewTableViewCell)
}

class ReviewTableViewCell: UITableViewCell {

    static let identifier = "ReviewTableViewCell"
    
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scoreContainer: UIView!
    @IBOutlet weak var starIcon: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    
    private var isExpanded: Bool = false
    weak var delegate: ReviewTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialUISetup()
    }

    private func initialUISetup() {
        self.selectionStyle = .none
        mainContainer.layer.cornerRadius = 8
        mainContainer.backgroundColor = .systemGray6
        scoreContainer.layer.cornerRadius = 8
        starIcon.image = UIImage(systemName: "star.fill")
        starIcon.contentMode = .scaleAspectFit
        starIcon.tintColor = .systemYellow
        var config = UIButton.Configuration.plain()
        let title = AttributedString("Read more", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]))
        config.attributedTitle = title
        config.baseForegroundColor = .systemBlue
        readMoreButton.configuration = config
        readMoreButton.contentHorizontalAlignment = .center
        readMoreButton.isHidden = true
    }
    
    func configure(with review: ReviewItem, isExpanded: Bool) {
        userAvatar.setImage(with: URL(string: review.authorDetails?.avatarPath ?? ""), placeholder: UIImage(systemName: "person.fill"))
        usernameLabel.text = review.authorDetails?.username ?? review.author ?? "Unknown"
        reviewText.text = review.content
        dateLabel.text = formattedDate(from: review.createdAt)
        
        if let rating = review.authorDetails?.rating {
            scoreLabel.text = "\(Int(rating * 10))%"
            scoreContainer.isHidden = false
        } else {
            scoreContainer.isHidden = true
        }

        self.isExpanded = isExpanded
        reviewText.numberOfLines = isExpanded ? 0 : 4

        let needsExpansion = review.content?.count ?? 0 > 250
        readMoreButton.isHidden = !needsExpansion
        var config = UIButton.Configuration.plain()
        let title = AttributedString(isExpanded ? "Read less" : "Read more", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]))
        config.attributedTitle = title
        config.baseForegroundColor = .systemBlue
        readMoreButton.configuration = config
    }
    
    private func formattedDate(from isoDateString: String?) -> String {
        guard let isoDateString = isoDateString else { return "" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        
        if let date = formatter.date(from: isoDateString) {
            return displayFormatter.string(from: date)
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: isoDateString) {
                return displayFormatter.string(from: date)
            }
        }
        
        return ""
    }
    
    
    @IBAction func readMoreTapped(_ sender: Any) {
        delegate?.didTapReadMore(in: self)
    }
}
