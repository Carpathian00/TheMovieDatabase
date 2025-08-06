//
//  ReviewModel.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import Foundation

struct ReviewModel: Codable {
    let id: Int?
    let page: Int?
    let results: [ReviewItem]?
    let totalPages: Int?
    let totalResults: Int?
    var hasMorePage: Bool {
        if page == totalPages {
            return false
        }
        return true
    }

    enum CodingKeys: String, CodingKey {
        case id, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct ReviewItem: Codable {
    let author: String?
    let content: String?
    let createdAt: String?
    let authorDetails: AuthorDetails?

    enum CodingKeys: String, CodingKey {
        case author, content
        case createdAt = "created_at"
        case authorDetails = "author_details"
    }
}

struct AuthorDetails: Codable {
    let name: String?
    let username: String?
    let avatarPath: String?
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case name, username, rating
        case avatarPath = "avatar_path"
    }
}
