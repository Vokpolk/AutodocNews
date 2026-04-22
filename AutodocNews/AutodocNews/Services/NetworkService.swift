//
//  NetworkService.swift
//  AutodocNews
//
//  Created by Александр Клопков on 22.04.2026.
//
import Foundation

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case networkError(String)
    case serverError(Int)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный адрес сервера"
        case .decodingError:
            return "Ошибка обработки данных от сервера"
        case .networkError(let message):
            return "Проблема с сетью: \(message)"
        case .serverError(let code):
            return "Сервер ответил ошибкой (код: \(code))"
        }
    }
}

final class NetworkService {
    
    // MARK: - Private Properties
    private let baseUrl = "https://webapi.autodoc.ru"
    
    // MARK: - Public Methods
    func fetchNews(on page: Int, with count: Int) async throws -> NewsResponse {
        let url = URL(string: "\(baseUrl)/api/news/\(page)/\(count)")
        
        guard let url else {
            throw NetworkError.invalidURL
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw NetworkError.networkError(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError("Incorrect answer from server")
        }
        if !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
            
        do {
            return try JSONDecoder().decode(NewsResponse.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
}
