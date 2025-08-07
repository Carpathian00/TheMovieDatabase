//
//  HomeTableBinding.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 07/08/25.
//

import RxSwift
import UIKit

extension HomeViewController {
    func bindViewModel() {
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

    func handleTableModification() {
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

    func hideCategoryButton() {
        guard categoryButtonTopConstraint.constant == 8 else { return }
        categoryButtonTopConstraint.constant = -52 // Or: -categoryButton.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.categoryButton.alpha = 0
        }
    }

    func showCategoryButton() {
        guard !isSearching else { return }
        guard categoryButtonTopConstraint.constant != 8 else { return }
        categoryButtonTopConstraint.constant = 8
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.categoryButton.alpha = 1
        }
    }
}

