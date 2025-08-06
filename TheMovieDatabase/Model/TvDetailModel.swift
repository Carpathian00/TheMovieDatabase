//
//  TvDetailModel.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import Foundation

struct TVDetail: Codable {
    let backdropPath: String?
    let createdBy: [CreatedBy]?
    let episodeRunTime: [Int]?
    let firstAirDate: String?
    let genres: [GenreDetail]?
    let homepage: String?
    let id: Int?
    let inProduction: Bool?
    let languages: [String]?
    let lastAirDate: String?
    let lastEpisodeToAir: LastEpisodeToAir?
    let name: String?
    let networks: [Network]?
    let numberOfEpisodes, numberOfSeasons: Int?
    let originCountry: [String]?
    let originalName, overview: String?
    let popularity: Double?
    let posterPath: String?
    let productionCompanies: [Network]?
    let productionCountries: [ProductionCountry]?
    let seasons: [Season]?
    let spokenLanguages: [SpokenLanguage]?
    let voteAverage: Double?
    let voteCount: Int?

    var formattedLastAirDate: String? {
            guard let lastAirDate = lastAirDate else { return nil }
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd MMMM yyyy"
            
            if let date = dateFormatterGet.date(from: lastAirDate) {
                return dateFormatterPrint.string(from: date)
            } else {
                return nil
            }
        }

    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case createdBy = "created_by"
        case episodeRunTime = "episode_run_time"
        case firstAirDate = "first_air_date"
        case genres, homepage, id
        case inProduction = "in_production"
        case languages
        case lastAirDate = "last_air_date"
        case lastEpisodeToAir = "last_episode_to_air"
        case name
        case networks
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case originCountry = "origin_country"
        case originalName = "original_name"
        case overview, popularity
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case seasons
        case spokenLanguages = "spoken_languages"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

struct CreatedBy: Codable {
    let id: Int?
    let creditID, name: String?
    let gender: Int?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case creditID = "credit_id"
        case name, gender
        case profilePath = "profile_path"
    }
}

struct LastEpisodeToAir: Codable {
    let airDate: String?
    let episodeNumber, id: Int?
    let name, overview, productionCode: String?
    let seasonNumber: Int?
    let stillPath: String?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case id, name, overview
        case productionCode = "production_code"
        case seasonNumber = "season_number"
        case stillPath = "still_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

struct Network: Codable {
    let name: String?
    let id: Int?
    let logoPath: String?
    let originCountry: String?

    enum CodingKeys: String, CodingKey {
        case name, id
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}

struct ProductionCountry: Codable {
    let iso3166_1, name: String?

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}

struct Season: Codable {
    let airDate: String?
    let episodeCount, id: Int?
    let name, overview, posterPath: String?
    let seasonNumber: Int?

    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeCount = "episode_count"
        case id, name, overview
        case posterPath = "poster_path"
        case seasonNumber = "season_number"
    }
}

struct SpokenLanguage: Codable {
    let englishName, iso639_1, name: String?

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso639_1 = "iso_639_1"
        case name
    }
}
