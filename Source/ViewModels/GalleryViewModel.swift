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

    var photos: [PhotoViewModel] = []
    
    let isLoading = Observable<Bool>(false)
    let requestFailed = Observable<String?>(nil)
    let insertedItems = Observable<[IndexPath]>([])

    var searchText: String = "" {
        didSet {
            provider.prepare(search: searchText)
        }
    }

    init(provider: PhotosSearchProvider) {
        self.provider = provider

        URLCache.shared.removeAllCachedResponses() // FIXME: remove
    }

    deinit {
        abortRequest()
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
                    PhotoViewModel(model: $0, provider: provider, size: .small)
                })
                let total = photos.count
                let range = max(total - newPhotos.count, 0) ..< total
                insertedItems.value = range.map { IndexPath(row: $0, section: 0) }
            }

        case .failure(let error):
            self.requestFailed.value = error.localizedDescription
        }
    }

    func abortRequest() {
        fetchRequest?.task.cancel()
    }
}
