//
//  MockMovieAndTvRepository.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 07/08/25.
//

import RxSwift
import Foundation

class MockMovieAndTvRepository: MovieAndTvRepositoryProtocol {
    var mockApiResponse: ApiResponse?
    var mockMovieDetail: MovieDetail?
    var mockTvDetail: TVDetail?
    var mockTrailerResult: TrailerResult?
    var mockMovieReviewResult: ReviewModel?
    var mockTvReviewResult: ReviewModel?
    
    var shouldReturnError = false

    func fetchItems(method: HTTPRequestMethod, url: String, headers: [String: String]?, params: [String: Any]?) -> Single<ApiResponse?> {
        return .just(mockApiResponse)
    }

    func fetchMovieDetail(id: Int) -> Single<MovieDetail?> {
        if shouldReturnError {
            return .error(NSError(domain: "Test", code: -2, userInfo: [NSLocalizedDescriptionKey: "Mock Error"]))
        }
        return .just(mockMovieDetail)
    }

    func fetchTvDetail(id: Int) -> Single<TVDetail?> {
        if shouldReturnError {
            return .error(NSError(domain: "Test", code: -3, userInfo: [NSLocalizedDescriptionKey: "Mock Error"]))
        }
        return .just(mockTvDetail)
    }

    func fetchTrailerData(id: Int) -> Single<TrailerResult?> {
        if shouldReturnError {
            return .error(NSError(domain: "Test", code: -4, userInfo: [NSLocalizedDescriptionKey: "Mock Error"]))
        }
        return .just(mockTrailerResult)
    }

    func fetchMovieReviews(id: Int, page: Int) -> Single<ReviewModel?> {
        if shouldReturnError {
            return .error(NSError(domain: "Test", code: -5, userInfo: [NSLocalizedDescriptionKey: "Mock Error"]))
        }
        return .just(mockMovieReviewResult)
    }

    func fetchTvReviews(id: Int, page: Int) -> Single<ReviewModel?> {
        if shouldReturnError {
            return .error(NSError(domain: "Test", code: -6, userInfo: [NSLocalizedDescriptionKey: "Mock Error"]))
        }
        return .just(mockTvReviewResult)
    }
    
    func search(query: String?, type: String) -> Single<ApiResponse?> {
        if shouldReturnError {
            return .error(NSError(domain: "Test", code: -6, userInfo: [NSLocalizedDescriptionKey: "Mock Error"]))
        }
        return .just(mockApiResponse)

    }
}
