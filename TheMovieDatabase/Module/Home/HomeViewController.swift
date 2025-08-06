//
//  HomeViewController.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 04/08/25.
//

import UIKit
import Nuke
import RxSwift
import RxCocoa
import XLPagerTabStrip

enum HomeCellItem {
    case success(ItemData)
    case loading
    case error(NetworkError)
}

enum HomeType {
    case movie
    case tvShow
}

enum CategoryType: String, CaseIterable {
    case popular = "Popular"
    case trending = "Trending"
    case topRated = "Top Rated"
}

class HomeViewController: UIViewController {
    // UI Components
    private lazy var mainTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.sectionFooterHeight = 0.0
        table.register(UINib(nibName: "MovieAndTvTableCell", bundle: nil), forCellReuseIdentifier: MovieAndTvTableCell.identifier)
        table.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.identifier)
        table.register(ErrorCell.self, forCellReuseIdentifier: ErrorCell.identifier)
        return table
    }()
    
    private let categoryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        
        // Title
        config.title = "Popular"
        config.attributedTitle = AttributedString("Popular", attributes: AttributeContainer([
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]))

        // Chevron
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        config.image = UIImage(systemName: "chevron.down", withConfiguration: chevronConfig)
        config.imagePlacement = .trailing
        config.imagePadding = 6

        // Alignment
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        config.titleAlignment = .leading

        // Appearance
        config.baseBackgroundColor = .systemBackground
        config.baseForegroundColor = .label
        config.cornerStyle = .medium

        let button = UIButton(configuration: config, primaryAction: nil)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private let refreshControl = UIRefreshControl()
    private var categoryButtonTopConstraint: NSLayoutConstraint!
    
    // Data
    let homeType: HomeType
    let viewModel: HomeViewModel = HomeViewModel(repository: MovieAndTvRepository())
    private var disposeBag = DisposeBag()
    private var currentCategory: CategoryType = .popular
    private let movieEndpoints: [CategoryType: Endpoint.Movie] = [
        .popular : .popularMovie,
        .trending : .trendingMovieDay,
        .topRated : .discoverMovie
    ]
    
    private let tvEndpoints: [CategoryType: Endpoint.TVShow] = [
        .popular : .popularTV,
        .trending : .trendingTVsDay,
        .topRated : .discoverTV
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        handleTableModification()
    }
    
    init(homeType: HomeType) {
        self.homeType = homeType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        mainTableView.refreshControl = refreshControl
        
        view.addSubview(categoryButton)
        view.addSubview(mainTableView)
        
        categoryButtonTopConstraint = categoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        NSLayoutConstraint.activate([
            categoryButtonTopConstraint,
            categoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 44),
            
            mainTableView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 8),
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupCategoryMenu()
    }
    
    private func configEndpointAndHit() {
        viewModel.currentPage = 1
        
        switch homeType {
        case .movie:
            guard let endPoint = movieEndpoints[currentCategory] else { return }
            viewModel.getMovieList(endpoint: endPoint, page: viewModel.currentPage)
        case .tvShow:
            guard let endPoint = tvEndpoints[currentCategory] else { return }
            viewModel.getTVList(endpoint: endPoint, page: viewModel.currentPage)
        }

        setupCategoryMenu(selected: currentCategory)
        updateCategoryButtonTitle(currentCategory.rawValue)
    }
    
    func updateCategoryButtonTitle(_ newTitle: String) {
        var config = categoryButton.configuration
        config?.title = newTitle
        config?.attributedTitle = AttributedString(newTitle, attributes: AttributeContainer([
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]))
        categoryButton.configuration = config
    }
    
    private func setupCategoryMenu(selected: CategoryType = .popular) {
        let popularAction = UIAction(title: "Popular", state: selected == .popular ? .on : .off) { [weak self] _ in
            self?.currentCategory = .popular
            self?.configEndpointAndHit()
        }
        let trendingAction = UIAction(title: "Trending", state: selected == .trending ? .on : .off) { [weak self] _ in
            self?.currentCategory = .trending
            self?.configEndpointAndHit()
        }
        let topRatedAction = UIAction(title: "Top Rated", state: selected == .topRated ? .on : .off) { [weak self] _ in
            self?.currentCategory = .topRated
            self?.configEndpointAndHit()
        }
        
        let menu = UIMenu(title: "Select Category", options: .displayInline, children: [
            popularAction, trendingAction, topRatedAction
        ])
        
        categoryButton.menu = menu
        categoryButton.showsMenuAsPrimaryAction = true
    }
    
    @objc func handleRefresh() {
        self.configEndpointAndHit()
    }
    
    private func bindViewModel() {
        viewModel.items
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        viewModel.items.bind(to: mainTableView.rx.items) { tableView, row, item in
            switch item {
            case .success(let itemData):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieAndTvTableCell.identifier, for: IndexPath(row: row, section: 0)) as? MovieAndTvTableCell else {
                    return UITableViewCell()
                }
                cell.configure(itemModel: itemData, index: row + 1)
                
                return cell
                
            case .loading:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.identifier, for: IndexPath(row: row, section: 0)) as? LoadingCell else {
                    return UITableViewCell()
                }
                cell.spinner.startAnimating()
                return cell
                
            case .error(let error):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ErrorCell.identifier, for: IndexPath(row: row, section: 0)) as? ErrorCell else {
                    return UITableViewCell()
                }
                cell.configure(
                    logo: UIImage(systemName: "exclamationmark.triangle"),
                    title: error.description
                )
                
                cell.retryButton.rx.tap.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.configEndpointAndHit()
                }
                .disposed(by: self.disposeBag)
                
                return cell
            }
        }
        .disposed(by: disposeBag)
        
        configEndpointAndHit()
    }
    
    private func handleTableModification() {
        mainTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let item = self.viewModel.items.value[indexPath.row]
                
                switch item {
                case .success(let itemData):
                    guard let id = itemData.id else { return }
                    
                    let repo = MovieAndTvRepository()
                    let vm = DetailViewModel(id: id, type: homeType, repository: repo)
                    let vc = DetailViewController(viewModel: vm)
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        mainTableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let `self` = self else { return }
                
                let items = self.viewModel.items.value
                
                if indexPath.row == items.count - 1 {
                    if viewModel.isUpdating == false {
                        self.viewModel.currentPage += 1
                        self.viewModel.getMovieList(endpoint: .popularMovie, page: viewModel.currentPage)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        mainTableView.rx.contentOffset
            .map { $0.y }
            .distinctUntilChanged()
            .pairwise()
            .subscribe(onNext: { [weak self] previous, current in
                guard let self = self else { return }
                if current > previous + 10 && current > 0 {
                    hideCategoryButton()
                } else if current < previous - 10 {
                    self.showCategoryButton()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func hideCategoryButton() {
        guard categoryButtonTopConstraint.constant == 8 else { return }
        categoryButtonTopConstraint.constant = -60 // Or: -categoryButton.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.categoryButton.alpha = 0
        }
    }
    
    private func showCategoryButton() {
        guard categoryButtonTopConstraint.constant != 8 else { return }
        categoryButtonTopConstraint.constant = 8
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.categoryButton.alpha = 1
        }
    }
}

extension HomeViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        return IndicatorInfo(title: homeType == .movie ? "Movies" : "TV Shows")
    }
}
