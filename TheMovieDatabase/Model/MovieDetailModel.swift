//
//  MovieDetailModel.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import Foundation

struct MovieDetail: Codable {
    let adult: Bool?
    let budget: Int?
    let genres: [GenreDetail]?
    let homepage: String?
    let id: Int?
    let imdbID, originalLanguage, originalTitle, overview: String?
    let popularity: Double?
    let posterPath: String?
    let releaseDate: String?
    let runtime: Int?
    let title: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?
    
    var releaseYear: String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: releaseDate ?? "") {
                dateFormatter.dateFormat = "yyyy"
                return dateFormatter.string(from: date)
            }
            return nil
        }


    enum CodingKeys: String, CodingKey {
        case adult
        case budget
        case genres
        case homepage
        case id
        case imdbID
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case runtime
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    
}

struct GenreDetail: Codable {
    let id: Int?
    let name: String?
}

