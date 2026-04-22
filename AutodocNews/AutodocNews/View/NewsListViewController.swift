//
//  ViewController.swift
//  AutodocNews
//
//  Created by Александр Клопков on 22.04.2026.
//

import UIKit

class NewsListViewController: UIViewController {
    
    // MARK: - Private Properties
    private let networkService = NetworkService()

    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        fetchFirstNews()
    }

    // MARK: - Private Methods
    private func fetchFirstNews() {
        Task {
            do {
                let response = try await networkService.fetchNews(on: 1, with: 15)
                
                print("Успех! Загружено новостей: \(response.news.count)")
                
                if let firstNews = response.news.first {
                    print("Заголовок первой новости: \(firstNews.title)")
                }
                
            } catch {
                print("Ошибка загрузки: \(error.localizedDescription)")
            }
        }
    }
}

