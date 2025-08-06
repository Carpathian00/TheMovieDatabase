//
//  DetailViewModel.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 04/08/25.
//

import RxSwift
import RxCocoa
import UIKit

enum DetailTableSection: Int, CaseIterable {
    case trailer = 0
    case detail
    case reviews
}

class DetailViewModel {
    // Parameter
    let id: Int
    let type: HomeType
    
    // UI Update
    internal var onReloadSections = PublishRelay<([Int], UITableView.RowAnimation)>()
    let onReloadAll = PublishRelay<Void>()

    // Class Utility
    var currentReviewPage = 1
    let repository: MovieAndTvRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    // Data
    var movieDetail: MovieDetail? = nil
    var tvDetail: TVDetail? = nil
    var trailerData: TrailerResult? = nil
    var reviewsData: [ReviewItem] = []
    var hasMoreReviewPages: Bool = true
    
    init(id: Int, type: HomeType, repository: MovieAndTvRepositoryProtocol) {
        self.id = id
        self.type = type
        self.repository = repository
    }
    
    func loadInitialData() {
        if type == .movie {
            getMovieDetail()
        } else {
            getTVDetail()
        }
        
        getTrailerData()
        getReviewData()
    }
    
    private func reloadPageSections(_ sections: [DetailTableSection]? = nil, withAnimation: Bool = false) {
        let indexSet = (sections ?? DetailTableSection.allCases).compactMap {
            return $0.rawValue
        }
        self.onReloadSections.accept((indexSet, withAnimation ? .automatic : .none))
    }
    func getTrailerData() {
        repository.fetchTrailerData(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] trailer in
                self?.trailerData = trailer
                self?.reloadPageSections([.trailer])
            }, onFailure: { error in
                print("Trailer fetch error:", error)
                self.reloadPageSections([.trailer])
            })
            .disposed(by: disposeBag)
    }
    
    func getMovieDetail() {
        repository.fetchMovieDetail(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] detail in
                self?.movieDetail = detail
                self?.reloadPageSections([.detail])
            }, onFailure: { error in
                print("Movie detail fetch error:", error)
                self.reloadPageSections([.detail])
            })
            .disposed(by: disposeBag)
    }
    
    func getTVDetail() {
        repository.fetchTvDetail(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] detail in
                self?.tvDetail = detail
                self?.reloadPageSections([.detail])
            }, onFailure: { error in
                print("TV detail fetch error:", error)
                self.reloadPageSections([.detail])
            })
            .disposed(by: disposeBag)
    }
    
    func getReviewData() {
        let reviewFetch: Single<ReviewModel?> = {
            switch type {
            case .movie:
                return repository.fetchMovieReviews(id: id, page: currentReviewPage)
            case .tvShow:
                return repository.fetchTvReviews(id: id, page: currentReviewPage)
            }
        }()
        
        reviewFetch
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self, let results = result?.results else { return }
                
                self.hasMoreReviewPages = result?.hasMorePage ?? false
                self.reviewsData += results
                self.reloadPageSections([.reviews])
            }, onFailure: { error in
                print("Reviews fetch error:", error)
                self.reloadPageSections([.reviews])
            })
            .disposed(by: disposeBag)
    }
}
