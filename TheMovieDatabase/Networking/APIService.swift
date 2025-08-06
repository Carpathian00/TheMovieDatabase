//
//  APIService.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 04/08/25.
//

import Foundation
import RxSwift

enum HTTPRequestMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case DELETE = "DELETE"
    case OPTIONS = "OPTIONS"
    case TRACE = "TRACE"
    case PATCH = "PATCH"
}

class APIService {
    
    static let shared = APIService()
    
    public func callApi(method: HTTPRequestMethod, url: String, headers: [String: String]? = nil, requestBodyParams: [String: Any]? = nil, completion: @escaping ((Result<Data?, Error>) -> Void)) {
        
        guard var urlComponents = URLComponents(string: url) else {
             completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
             return
         }
        
        // Convert requestBodyParams if the method is GET
        if let params = requestBodyParams, method == .GET {
            urlComponents.queryItems = params.map({ (key, value) in
                URLQueryItem(name: key, value: "\(value)")
            })
        }
        
        // Convert back to URL
        guard let finalURL = urlComponents.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not construct URL"])))
            return
        }
        
        // Set method
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = method.rawValue
        
        // Fill headers if any
        if let unwrappedHeaders = headers {
            for (key, value) in unwrappedHeaders {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Fill request body parameters for POST and PUT method
        if let parameters = requestBodyParams, (method == .POST || method == .PUT)  {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                print("Error when serializing request body parameters")
                return
            }
        }
        
        // Create URL task
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                
                if let data = data {
                    completion(.success(data))
                } else {
                    let dataError = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the server."])
                    completion(.failure(dataError))
                }
                
            } else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let responseError = NSError(domain: "ResponseError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response with status code: \(statusCode)"])
                completion(.failure(responseError))
            }
        }
        
        task.resume()
    }
}

extension APIService {
    // RxSwift Observable Wrapper
    func rx_callApi(method: HTTPRequestMethod, url: String, headers: [String: String]?, params: [String: Any]?) -> Single<Data?> {
        return Single.create { single in
            self.callApi(method: method, url: url, headers: headers, requestBodyParams: params) { result in
                switch result {
                case .success(let data):
                    single(.success(data))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
}

