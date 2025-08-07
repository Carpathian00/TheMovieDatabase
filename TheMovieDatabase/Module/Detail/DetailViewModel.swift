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
    var onReloadSections = PublishRelay<([Int])>()
    let onReloadAll = PublishRelay<Void>()

    // Class Utility
    var currentReviewPage = 1
    let repository: MovieAndTvRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    // Data
    var isDetailLoading: Bool = false
    var detailError: NetworkError? = nil
    var movieDetail: MovieDetail? = nil
    var tvDetail: TVDetail? = nil
    var trailerData: TrailerResult? = nil
    var isReviewLoading: Bool = false
    var reviewsData: [ReviewItem] = []
    var reviewError: NetworkError? = nil
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
    
    private func reloadPageSections(_ sections: [DetailTableSection]? = nil) {
        let indexSet = (sections ?? DetailTableSection.allCases).compactMap {
            return $0.rawValue
        }
        self.onReloadSections.accept((indexSet))
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
        isDetailLoading = true
        reloadPageSections([.detail])

        repository.fetchMovieDetail(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] detail in
                self?.detailError = nil
                self?.movieDetail = detail
                self?.isDetailLoading = false
                self?.reloadPageSections([.detail])
            }, onFailure: { error in
                print("Movie detail fetch error:", error)
                let errorCode = ErrorMapper.map(error)
                self.detailError = errorCode
                self.isDetailLoading = false
                self.reloadPageSections([.detail])
            })
            .disposed(by: disposeBag)
    }
    
    func getTVDetail() {
        isDetailLoading = true
        reloadPageSections([.detail])

        repository.fetchTvDetail(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] detail in
                self?.detailError = nil
                self?.tvDetail = detail
                self?.isDetailLoading = false
                self?.reloadPageSections([.detail])
            }, onFailure: { error in
                print("TV detail fetch error:", error)
                let errorCode = ErrorMapper.map(error)
                self.detailError = errorCode
                self.isDetailLoading = false
                self.reloadPageSections([.detail])
            })
            .disposed(by: disposeBag)
    }
    
    func getReviewData() {
        isReviewLoading = true
        reloadPageSections([.reviews])

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
                self.reviewError = nil
                self.hasMoreReviewPages = result?.hasMorePage ?? false
                self.reviewsData += results
                self.isReviewLoading = false
                self.reloadPageSections([.reviews])
            }, onFailure: { error in
                print("Reviews fetch error:", error)
                let errorCode = ErrorMapper.map(error)
                self.reviewError = errorCode
                self.isReviewLoading = false
                self.reloadPageSections([.reviews])
            })
            .disposed(by: disposeBag)
    }
}
