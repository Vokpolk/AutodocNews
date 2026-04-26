//
//  ViewController.swift
//  AutodocNews
//
//  Created by Александр Клопков on 22.04.2026.
//

import UIKit
import Combine

@MainActor
class NewsListViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: NewsListViewModel
    private var cancellables = Set<AnyCancellable>()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsItem>?

    // MARK: - Initializers
    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        configureDataSource()
        setupBindings()
        
        Task {
            await viewModel.loadNews()
        }
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Autodoc News"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.register(NewsListCell.self, forCellWithReuseIdentifier: NewsListCell.identifier)
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, layoutEnvironment in
            let isPad = layoutEnvironment.traitCollection.userInterfaceIdiom == .pad
            
            let itemWidth: NSCollectionLayoutDimension = isPad ? .fractionalWidth(0.5) : .fractionalWidth(1.0)
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: itemWidth,
                heightDimension: .estimated(300)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 8,
                bottom: 0,
                trailing: 8
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: 8,
                bottom: 16,
                trailing: 8
            )
            section.interGroupSpacing = 16
            
            return section
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, NewsItem>(
            collectionView: collectionView
        ) { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewsListCell.identifier,
                for: indexPath
            ) as? NewsListCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    private func setupBindings() {
        viewModel.$news
            .receive(on: RunLoop.main)
            .sink { [weak self] news in
                self?.applySnapshot(with: news)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showErrorAlert(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if isLoading && self?.viewModel.news.isEmpty == true {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    private func applySnapshot(with news: [NewsItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NewsItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(news)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let newsItem = dataSource?.itemIdentifier(for: indexPath) else { return }
        let detailVC = NewsDetailViewController(urlString: newsItem.fullUrl)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pos = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        if pos > (contentHeight - screenHeight - 100) {
            Task {
                await viewModel.loadNews()
            }
        }
    }
}
