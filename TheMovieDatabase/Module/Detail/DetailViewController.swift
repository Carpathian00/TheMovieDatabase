//
//  DetailViewController.swift
//  NetflixClone
//
//  Created by Adlan Nourindiaz on 12/04/23.
//

import UIKit
import WebKit
import RxSwift

class DetailViewController: UIViewController {
    // UI Components
    private lazy var movieDetailLayout: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.sectionFooterHeight = 0.0
        table.sectionHeaderTopPadding = 0
        
        table.register(UINib(nibName: "TrailerTableViewCell", bundle: nil), forCellReuseIdentifier: TrailerTableViewCell.identifier)
        table.register(UINib(nibName: "MovieDetailTableViewCell", bundle: nil), forCellReuseIdentifier: MovieDetailTableViewCell.identifier)
        table.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: ReviewTableViewCell.identifier)
        table.register(LoadMoreReviewCell.self, forCellReuseIdentifier: LoadMoreReviewCell.identifier)
        
        return table
    }()
    
    // Class Utility
    private let disposeBag = DisposeBag()
    private let viewModel: DetailViewModel
    var expandedReviews: Set<Int> = []
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        bindViewModel()
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupTableView() {
        view.addSubview(movieDetailLayout)
        
        NSLayoutConstraint.activate([
            movieDetailLayout.topAnchor.constraint(equalTo: view.topAnchor),
            movieDetailLayout.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            movieDetailLayout.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            movieDetailLayout.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        movieDetailLayout.delegate = self
        movieDetailLayout.dataSource = self
    }
    
    private func bindViewModel() {
        viewModel.onReloadSections
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (sectionIndices, animation) in
                let indexSet = IndexSet(sectionIndices)
                self?.movieDetailLayout.reloadData()
                self?.movieDetailLayout.reloadSections(indexSet, with: animation)
            })
            .disposed(by: disposeBag)
        
        viewModel.onReloadAll
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.movieDetailLayout.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.loadInitialData()
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DetailTableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = DetailTableSection(rawValue: section)
        
        switch sectionType {
        case .trailer:
            return 1
        case .detail:
            return 1
        case .reviews:
            let count = viewModel.reviewsData.count
            return viewModel.hasMoreReviewPages ? count + 1 : count
        case nil:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = DetailTableSection(rawValue: section), sectionType == .reviews else {
            return nil
        }
        
        return ReviewSectionHeaderView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = DetailTableSection(rawValue: section), sectionType == .reviews else {
            return 0
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionType = DetailTableSection(rawValue: indexPath.section)
        
        switch sectionType {
        case .trailer:
            if viewModel.trailerData?.key == nil {
                return 330
            }
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = DetailTableSection(rawValue: indexPath.section)
        
        switch sectionType {
        case .trailer:
            guard let cell = movieDetailLayout.dequeueReusableCell(withIdentifier: TrailerTableViewCell.identifier, for: indexPath) as? TrailerTableViewCell else { return UITableViewCell() }
            
            if viewModel.type == .movie {
                cell.configure(trailerUrlKey: viewModel.trailerData?.key, posterUrl: viewModel.movieDetail?.posterPath ?? "")
            } else {
                cell.configure(trailerUrlKey: viewModel.trailerData?.key, posterUrl: viewModel.tvDetail?.posterPath ?? "")
            }
            
            return cell
        case .detail:
            guard let cell = movieDetailLayout.dequeueReusableCell(withIdentifier: MovieDetailTableViewCell.identifier, for: indexPath) as? MovieDetailTableViewCell else { return UITableViewCell() }

            if viewModel.type == .movie {
                cell.configureByMovie(detailModel: viewModel.movieDetail)
            } else {
                cell.configureByTv(detailModel: viewModel.tvDetail)
            }
            return cell
            
        case .reviews:
            let isLastRow = indexPath.row == viewModel.reviewsData.count

            if viewModel.reviewsData.isEmpty {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyReviewCell")
                cell.selectionStyle = .none
                cell.textLabel?.text = "No reviews yet."
                cell.textLabel?.textColor = .systemGray
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 16)
                return cell
            }

            if isLastRow && viewModel.hasMoreReviewPages {
                let cell = tableView.dequeueReusableCell(withIdentifier: LoadMoreReviewCell.identifier, for: indexPath) as! LoadMoreReviewCell
                cell.onTapLoadMore = { [weak self] in
                    self?.viewModel.currentReviewPage += 1
                    self?.viewModel.getReviewData()
                }
                return cell
            }

            guard let data = viewModel.reviewsData[safe: indexPath.row],
                  let cell = movieDetailLayout.dequeueReusableCell(withIdentifier: ReviewTableViewCell.identifier, for: indexPath) as? ReviewTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: data, isExpanded: expandedReviews.contains(indexPath.row))
            cell.delegate = self
            return cell
        case nil:
            return UITableViewCell()
        }
    }
}

extension DetailViewController: ReviewTableViewCellDelegate {
    func didTapReadMore(in cell: ReviewTableViewCell) {
        guard let indexPath = movieDetailLayout.indexPath(for: cell) else { return }

        if expandedReviews.contains(indexPath.row) {
            expandedReviews.remove(indexPath.row)
        } else {
            expandedReviews.insert(indexPath.row)
        }

        movieDetailLayout.reloadRows(at: [indexPath], with: .automatic)
    }
}
