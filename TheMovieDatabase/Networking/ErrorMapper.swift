//
//  ErrorEnum.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 05/08/25.
//

import Foundation

enum NetworkError: Error {
    case unauthorized
    case notFound
    case serverError
    case unknown

    init(statusCode: Int) {
        switch statusCode {
        case 401: self = .unauthorized
        case 404: self = .notFound
        case 500...599: self = .serverError
        default: self = .unknown
        }
    }
    
    var description: String {
        switch self {
        case .unauthorized:
            return "You are not authorized. Please log in again."
        case .notFound:
            return "The requested resource could not be found."
        case .serverError:
            return "A server error occurred. Please try again later."
        case .unknown:
            return "An unknown error occurred. Please check your connection or try again."
        }
    }
}

struct ErrorMapper {
    static func map(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        
        if nsError.domain == "ResponseError", nsError.code != -1 {
            return NetworkError(statusCode: nsError.code)
        }
        
        return .unknown
    }
}
