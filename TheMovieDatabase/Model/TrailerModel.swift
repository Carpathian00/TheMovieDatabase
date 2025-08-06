//
//  TrailerModel.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import Foundation

struct MovieTrailer: Codable {
    let id: Int
    let results: [TrailerResult]
}

struct TrailerResult: Codable {
    let name: String
    let key: String
    let site: String
    let type: String
    let official: Bool
    let publishedAt: String
    let resultId: String
    
    enum CodingKeys: String, CodingKey {
        case name, key, site, type, official
        case publishedAt = "published_at"
        case resultId = "id"
    }
}
