//
//  HomeViewModel.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 04/08/25.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    // Class Utility
    var currentPage = 1
    var isUpdating: Bool = false
    private let repository: MovieAndTvRepositoryProtocol
    private let apiService = APIService.shared
    private let disposeBag = DisposeBag()
    
    // Data
    let items = BehaviorRelay<[HomeCellItem]>(value: [])
    var errorCode: NetworkError? = nil
    
    init(repository: MovieAndTvRepositoryProtocol) {
        self.repository = repository
    }
    
    func getMovieList(endpoint: Endpoint.Movie, page: Int) {
        self.getItems(endpoint: endpoint.fullPath, page: page)
    }
    
    func getTVList(endpoint: Endpoint.TVShow, page: Int) {
        self.getItems(endpoint: endpoint.fullPath, page: page)
    }
    
    private func getItems(endpoint: String, page: Int) {
        isUpdating = true
        let params: [String: Any] = [
            "api_key": APIConfig.API_KEY,
            "page": page
        ]
        
        if page == 1 {
            items.accept([.loading])
        }
        
        repository.fetchItems(method: .GET, url: endpoint, headers: nil, params: params)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] result in
                    guard let `self` = self else { return }
                    print(result?.page ?? 0, result?.totalPages ?? 0)
                    
                    var newItems = (result?.results ?? []).map { HomeCellItem.success($0) }
                    
                    if !(result?.page == result?.totalPages) {
                        newItems += [.loading]
                    }

                    if page == 1 {
                        self.items.accept(newItems)
                    } else {
                        var current = self.items.value.filter { if case .loading = $0 { return false } else { return true } }
                        current += newItems
                        self.items.accept(current)
                    }
                    
                    isUpdating = false
                }, onFailure: { [weak self] error in
                    guard let `self` = self else { return }
                    
                    let errorCode = ErrorMapper.map(error)
                    self.items.accept([.error(errorCode)])
                    isUpdating = false
                })
            .disposed(by: disposeBag)
    }
}
