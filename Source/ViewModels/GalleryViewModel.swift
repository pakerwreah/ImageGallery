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
    private var fetchRequest: AnyCancellable?

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

    func photoViewModel(at indexPath: IndexPath) -> PhotoViewModel? {
        if !photos.isEmpty {
            return photos[indexPath.row].photoViewModel
        }
        return nil
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

            fetchRequest = provider.fetch()
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }

                    self.isLoading = false

                    switch completion {
                    case .failure(let error):
                        self.requestFailed = error
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] newPhotos in
                    guard let self = self, !newPhotos.isEmpty else { return }

                    // append the photos to the end of the collection view
                    self.photos.append(contentsOf: newPhotos.map {
                        GalleryCellViewModel(model: $0, provider: self.provider)
                    })
                    let total = self.photos.count
                    let range = max(total - newPhotos.count, 0) ..< total
                    self.insertedIndexes.send(range.map { IndexPath(row: $0, section: 0) })
                })
        }
    }

    func abortRequest() {
        fetchRequest?.cancel()
    }
}
