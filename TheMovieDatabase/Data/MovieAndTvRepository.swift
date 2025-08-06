//
//  MovieAndTvRepository.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 05/08/25.
//

import RxSwift
import Foundation

protocol MovieAndTvRepositoryProtocol {
    func fetchItems(method: HTTPRequestMethod, url: String, headers: [String: String]?, params: [String: Any]?) -> Single<ApiResponse?>
    func fetchMovieDetail(id: Int) -> Single<MovieDetail?>
    func fetchTvDetail(id: Int) -> Single<TVDetail?>
    func fetchTrailerData(id: Int) -> Single<TrailerResult?>
    func fetchMovieReviews(id: Int, page: Int) -> Single<ReviewModel?>
    func fetchTvReviews(id: Int, page: Int) -> Single<ReviewModel?>
}

class MovieAndTvRepository: MovieAndTvRepositoryProtocol {
    private let apiService = APIService.shared
    
    func fetchItems(method: HTTPRequestMethod, url: String, headers: [String: String]?, params: [String: Any]?) -> Single<ApiResponse?> {
        apiService.rx_callApi(method: method, url: url, headers: headers, params: params)
            .flatMap { data -> Single<ApiResponse?> in
                guard let data = data else { return .just(nil) }
                
                do {
                    let decoded = try JSONDecoder().decode(ApiResponse.self, from: data)
                    return .just(decoded)
                } catch {
                    return .error(error)
                }
            }
    }

    func fetchMovieDetail(id: Int) -> Single<MovieDetail?> {
        let url = Endpoint.Movie.movieDetail(id: id).fullPath
        let params = [
            "api_key": APIConfig.API_KEY,
            "language": "en-US"
        ]
        
        return apiService.rx_callApi(method: .GET, url: url, headers: nil, params: params)
            .flatMap { data -> Single<MovieDetail?> in
                guard let data = data else { return .just(nil) }
                
                do {
                    let decoded = try JSONDecoder().decode(MovieDetail.self, from: data)
                    return .just(decoded)
                } catch {
                    return .error(error)
                }
            }
    }
    
    func fetchTvDetail(id: Int) -> Single<TVDetail?> {
        let url = Endpoint.TVShow.tvDetail(id: id).fullPath
        let params = [
            "api_key": APIConfig.API_KEY,
            "language": "en-US"
        ]

        return apiService.rx_callApi(method: .GET, url: url, headers: nil, params: params)
            .flatMap { data -> Single<TVDetail?> in
                guard let data = data else { return .just(nil) }
                
                do {
                    let decoded = try JSONDecoder().decode(TVDetail.self, from: data)
                    return .just(decoded)
                } catch {
                    return .error(error)
                }
            }
    }
    
    func fetchTrailerData(id: Int) -> Single<TrailerResult?> {
        let url = Endpoint.videos(id: id).fullPath
        let params = [
            "api_key": APIConfig.API_KEY,
            "language": "en-US"
        ]
        
        return apiService.rx_callApi(method: .GET, url: url, headers: nil, params: params)
            .flatMap { data -> Single<TrailerResult?> in
                guard let data = data else { return .just(nil) }
                
                do {
                    let decoded = try JSONDecoder().decode(MovieTrailer.self, from: data)
                    var trailerData = [TrailerResult]()
                    decoded.results.forEach { trailer in
                        if trailer.type == "Trailer" && trailer.site == "YouTube" {
                            trailerData.append(trailer)
                        }
                    }
                    
                    return .just(trailerData.first)
                } catch {
                    return .error(error)
                }
            }
    }
    
    func fetchMovieReviews(id: Int, page: Int) -> Single<ReviewModel?> {
        let url = Endpoint.Movie.movieReviews(id: id).fullPath
        let params: [String: Any] = [
            "api_key": APIConfig.API_KEY,
            "language": "en-US",
            "page": page
        ]

        return apiService.rx_callApi(method: .GET, url: url, headers: nil, params: params)
            .flatMap { data -> Single<ReviewModel?> in
                guard let data = data else { return .just(nil) }

                do {
                    let decoded = try JSONDecoder().decode(ReviewModel.self, from: data)
                    return .just(decoded)
                } catch {
                    return .error(error)
                }
            }
    }

    func fetchTvReviews(id: Int, page: Int) -> Single<ReviewModel?> {
        let url = Endpoint.TVShow.tvReviews(id: id).fullPath
        let params: [String: Any] = [
            "api_key": APIConfig.API_KEY,
            "language": "en-US",
            "page": page
        ]

        return apiService.rx_callApi(method: .GET, url: url, headers: nil, params: params)
            .flatMap { data -> Single<ReviewModel?> in
                guard let data = data else { return .just(nil) }

                do {
                    let decoded = try JSONDecoder().decode(ReviewModel.self, from: data)
                    return .just(decoded)
                } catch {
                    return .error(error)
                }
            }
    }
}
