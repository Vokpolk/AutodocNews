//
//  ImageService.swift
//  AutodocNews
//
//  Created by Александр Клопков on 26.04.2026.
//

import UIKit

final class ImageService {
    // MARK: - Static properties
    static let shared = ImageService()
    
    // MARK: - Private Properties
    private let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Initializers
    private init() {
        cache.countLimit = 30
    }
    
    // MARK: - Public Methods
    func fetchImage(from urlString: String) async -> UIImage? {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            cache.setObject(image, forKey: urlString as NSString)
            return image
        } catch {
            print("Ошибка загрузки картинки: \(error)")
            return nil
        }
    }
}
