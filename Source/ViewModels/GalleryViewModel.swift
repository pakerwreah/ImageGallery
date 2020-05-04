//
//  GalleryViewModel.swift
//  ImageGallery
//
//  Created by Paker on 02/05/20.
//

import Foundation

class GalleryViewModel {
    private let provider: PhotosSearchProvider
    private var fetchRequest: NetworkRequest?

    var photos: [GalleryCellViewModel] = []

    let isLoading = Observable<Bool>(false)
    let requestFailed = Observable<NetworkError?>(nil)
    let insertedItems = Observable<[IndexPath]>([])

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
        return PhotoDetailViewModel(model: photos[indexPath.row].model, provider: provider)
    }

    func fetchImages() {
        if !isLoading.value {
            isLoading.value = true

            fetchRequest = provider.fetch { [weak self] result in
                self?.isLoading.value = false
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
                insertedItems.value = range.map { IndexPath(row: $0, section: 0) }
            }

        case .failure(let error):
            self.requestFailed.value = error
        }
    }

    func abortRequest() {
        fetchRequest?.task.cancel()
    }
}
