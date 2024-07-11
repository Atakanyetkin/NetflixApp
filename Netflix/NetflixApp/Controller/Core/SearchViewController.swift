//
//  SearchViewController.swift
//  NetflixApp
//
//  Created by atakan yetkin on 8.07.2024.
//

import UIKit

class SearchViewController: UIViewController {
   
    public var titles: [Title] = [Title]()
    
    private let discoveryTable: UITableView = {
       let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()
    
    private let searchController: UISearchController = {
       let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a movie or Tv show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
       
        view.addSubview(discoveryTable)
        discoveryTable.delegate = self
        discoveryTable.dataSource = self
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.tintColor = .white
        fetchDiscoverMovies()
        searchController.searchResultsUpdater = self
        
        
    }
    
    private func fetchDiscoverMovies() {
        APICaller.shared.getDiscoverMovies { result in
            switch result {
                case .success(let titles):
                    self.titles = titles
                    DispatchQueue.main.async {
                        self.discoveryTable.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoveryTable.frame = view.bounds
    }

}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        let title = titles[indexPath.row]
        let model = TitleViewModel(titleName: title.original_name ??  title.original_title ?? "Unknown name",  posterURL: title.poster_path ?? "")
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else {
            return
        }
        
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
                case .success(let videoElement):
                    DispatchQueue.main.async {
                        let vc = TitlePreviewViewController()
                        vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                   
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
}

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
                
                let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        resultsController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let titles):
                        resultsController.titles = titles
                        resultsController.searchResultCollectionView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
                
              
    }
    func searchResultViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
       
    }
}
