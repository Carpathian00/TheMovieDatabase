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

enum HomeType: String {
    case movie = "movie"
    case tvShow = "tv"
}

enum CategoryType: String, CaseIterable {
    case popular = "Popular"
    case trending = "Trending"
    case topRated = "Top Rated"
}

class HomeViewController: UIViewController {
    // UI Components
    lazy var mainTableView: UITableView = {
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
    
    let categoryButton: UIButton = {
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
    
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.showsCancelButton = false
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    var isSearching = false
    let refreshControl = UIRefreshControl()
    var categoryButtonTopConstraint: NSLayoutConstraint!
    
    // Data
    let homeType: HomeType
    let viewModel: HomeViewModel
    var disposeBag = DisposeBag()
    var currentCategory: CategoryType = .popular
    let movieEndpoints: [CategoryType: Endpoint.Movie] = [
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
        viewModel = HomeViewModel(repository: MovieAndTvRepository(), homeType: homeType)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        searchBar.placeholder = homeType == .movie ? "Search Movies" : "Search TV Shows"
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        mainTableView.refreshControl = refreshControl
        
        view.addSubview(searchBar)
        view.addSubview(categoryButton)
        view.addSubview(mainTableView)
        
        categoryButtonTopConstraint = categoryButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    
            categoryButtonTopConstraint,
            categoryButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 44),
            
            mainTableView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 8),
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        searchBar.delegate = self
        setupCategoryMenu()
    }
    
    func configEndpointAndHit() {
        if isSearching {
            viewModel.reloadSearch(homeType: homeType)
            return
        }
        
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
    
    func setupCategoryMenu(selected: CategoryType = .popular) {
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
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        viewModel.searchText.accept(searchBar.text ?? "")
        hideCategoryButton()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        viewModel.switchData(isSearching: isSearching)
        
        showCategoryButton()
        searchBar.resignFirstResponder()
        searchBar.text = ""
        viewModel.searchText.accept("")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = true
        viewModel.switchData(isSearching: isSearching)
        viewModel.searchText.accept(searchBar.text ?? "")
        hideCategoryButton()
        searchBar.resignFirstResponder()
    }
}

extension HomeViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        return IndicatorInfo(title: homeType == .movie ? "Movies" : "TV Shows")
    }
}
