//
//  NewsItem.swift
//  AutodocNews
//
//  Created by Александр Клопков on 22.04.2026.
//

import Foundation

enum Section: Hashable, Sendable {
    case main
}

struct NewsResponse: Decodable, Sendable {
    let news: [NewsItem]
    let totalCount: Int
}

struct NewsItem: Decodable, Hashable, Sendable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let url: String
    let fullUrl: String
    let titleImageUrl: String?
    let categoryType: String
}
