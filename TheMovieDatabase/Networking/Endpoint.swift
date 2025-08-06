//
//  Endpoint.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 05/08/25.
//

struct APIConfig {
    static let baseUrl = "https://api.themoviedb.org/3"
    static let API_KEY = "00d626f8a69df5cc36ec9689858d16b6"
}

enum Endpoint {
    case genreMovieList
    case search(type: String)
    case videos(id: Int)
    
    var fullPath: String {
        return APIConfig.baseUrl + path
    }
    
    var path: String {
        switch self {
        case .genreMovieList:
            return "/genre/movie/list"
            
        case .search(let type):
            return "/search/\(type)"
            
        case .videos(let id):
            return "/movie/\(id)/videos"
        }
    }
    
    enum Movie {
        case discoverMovie
        case popularMovie
        case trendingMovieDay
        case movieDetail(id: Int)
        case movieReviews(id: Int)
        
        var fullPath: String {
            return APIConfig.baseUrl + path
        }
        
        var path: String {
            switch self {
            case .discoverMovie:
                return "/discover/movie"
                
            case .popularMovie:
                return "/movie/popular"
                
            case .trendingMovieDay:
                return "/trending/movie/day"
                
            case .movieDetail(let id):
                return "/movie/\(id)"
                
            case .movieReviews(let id):
                return "/movie/\(id)/reviews"
            }
        }
    }
    
    enum TVShow {
        case discoverTV
        case popularTV
        case trendingTVsDay
        case tvDetail(id: Int)
        case tvReviews(id: Int)
        
        var fullPath: String {
            return APIConfig.baseUrl + path
        }
        
        var path: String {
            switch self {
            case .discoverTV:
                return "/discover/tv"
                
            case .popularTV:
                return "/tv/popular"
                
            case .trendingTVsDay:
                return "/trending/tv/day"
                
            case .tvDetail(let id):
                return "/tv/\(id)"

            case .tvReviews(let id):
                return "/tv/\(id)/reviews"
            }
        }
    }
}
