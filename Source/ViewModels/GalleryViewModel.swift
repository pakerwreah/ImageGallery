//
//  GalleryViewModel.swift
//  ImageGallery
//
//  Created by Paker on 02/05/20.
//

import Foundation
import Combine

class GalleryViewModel {
    private let provider: PhotosSearchProvider
    private var fetchRequest: NetworkRequest?

    @Published private(set) var isLoading = false
    @Published private(set) var requestFailed: NetworkError?
    @Published private(set) var photos: [GalleryCellViewModel] = []

    let insertedIndexes = PassthroughSubject<[IndexPath], Never>()

    var searchText: String = "" {
        didSet {
            provider.prepare(search: searchText)
        }
    }

    init(provider: PhotosSearchProvider) {
        self.provider = provider

        URLCache.shared.removeAllCachedResponses()
    }

    deinit {
        abortRequest()
    }

    func photoDetailViewModel(forItemAt indexPath: IndexPath) -> PhotoDetailViewModel {
        return PhotoDetailViewModel(model: photos[indexPath.row].photoViewModel.model, provider: provider)
    }

    func removeAll() {
        photos.removeAll()
    }

    func fetchImages() {
        if !isLoading {
            isLoading = true

            fetchRequest = provider.fetch { [weak self] result in
                self?.isLoading = false
                self?.fetchResult(result)
            }
        }
    }

    private func fetchResult(_ result: Result<[PhotoModel], NetworkError>) {
        switch result {
        case .success(let newPhotos):
            if !newPhotos.isEmpty {
                // append the photos to the end of the collection view
                photos.append(contentsOf: newPhotos.map {
                    GalleryCellViewModel(model: $0, provider: provider)
                })
                let total = photos.count
                let range = max(total - newPhotos.count, 0) ..< total
                insertedIndexes.send(range.map { IndexPath(row: $0, section: 0) })
            }

        case .failure(let error):
            self.requestFailed = error
        }
    }

    func abortRequest() {
        fetchRequest?.task.cancel()
    }
}
