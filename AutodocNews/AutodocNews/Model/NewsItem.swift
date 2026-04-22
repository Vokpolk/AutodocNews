//
//  NewsItem.swift
//  AutodocNews
//
//  Created by Александр Клопков on 22.04.2026.
//

import Foundation

struct NewsResponse: Decodable {
    let news: [NewsItem]
    let totalCount: Int
}

struct NewsItem: Decodable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let url: String
    let fullUrl: String
    let titleImageUrl: String
    let categoryType: String
}
