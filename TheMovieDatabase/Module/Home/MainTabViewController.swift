//
//  MainTabViewController.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import UIKit
import XLPagerTabStrip

class MainTabViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .systemBlue
        navigationController?.navigationBar.barTintColor = .systemBlue
        
        let titleLabel = UILabel()
        titleLabel.text = "The Movie Database"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.sizeToFit()
        let leftItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftItem
        
        settings.style.buttonBarBackgroundColor = .systemBackground
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .systemBlue
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 16)
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .label
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 10
        settings.style.buttonBarRightContentInset = 10
        
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let movieVC = HomeViewController(homeType: .movie)
        let tvVC = HomeViewController(homeType: .tvShow)
        
        return [movieVC, tvVC]
    }

}
