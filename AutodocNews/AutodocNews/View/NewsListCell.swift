//
//  NewsListCell.swift
//  AutodocNews
//
//  Created by Александр Клопков on 26.04.2026.
//

import UIKit

final class NewsListCell: UICollectionViewCell {
    static let identifier = "NewsListCell"
    
    // MARK: - Private Properties
    private var downloadTask: Task<Void, Never>?
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let imageLoader = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        
        imageView.image = nil
        titleLabel.text = nil
    }
    
    func configure(with item: NewsItem) {
        titleLabel.text = item.title
        imageView.image = nil
        
        guard let imageUrl = item.titleImageUrl else { return }
        
        imageLoader.startAnimating()
        
        downloadTask = Task {
            let image = await ImageService.shared.fetchImage(from: imageUrl)
            if !Task.isCancelled {
                await MainActor.run {
                    self.imageLoader.stopAnimating()
                    self.imageView.image = image
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.backgroundColor = .systemGray.withAlphaComponent(0.4)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 0
        
        [
            imageView,
            titleLabel,
            imageLoader
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            imageLoader.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageLoader.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
}
