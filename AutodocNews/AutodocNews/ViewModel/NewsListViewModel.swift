//
//  NewsListViewModel.swift
//  AutodocNews
//
//  Created by Александр Клопков on 22.04.2026.
//

import Foundation
import Combine

@MainActor
final class NewsListViewModel: ObservableObject {
    // MARK: - Published
    @Published private(set) var news: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let networkService: NetworkService
    private var currentPage = 1
    private let pageSize = 15
    private var canLoadMore = true
    
    // MARK: - Initializers
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    func loadNews() async {
        guard !isLoading && canLoadMore else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkService.fetchNews(on: currentPage, with: pageSize)
            
            if response.news.isEmpty {
                canLoadMore = false
            } else {
                self.news.append(contentsOf: response.news)
                currentPage += 1
            }
        } catch {
            self.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
