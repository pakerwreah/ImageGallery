//
//  GalleryCellViewModel.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation

class GalleryCellViewModel {
    let model: PhotoModel
    private let provider: PhotosSearchProvider
    private var imageRequest: NetworkRequest?
    let imageData = Observable<Data?>(nil)
    let downloadFailed = Observable<Bool>(false)
    let isLoading = Observable<Bool>(false)

    init(model: PhotoModel, provider: PhotosSearchProvider) {
        self.model = model
        self.provider = provider
    }

    func downloadImage() {
        isLoading.value = true
        // download small photo to show in the collection view
        imageRequest = provider.downloadImage(photo: model, size: .small) { [weak self] result in
            guard let self = self else { return }

            self.isLoading.value = false

            switch result {
            case .success(let data):
                self.downloadFailed.value = false
                self.imageData.value = data

            case .failure:
                self.downloadFailed.value = true
                self.imageData.value = nil
            }
            // TODO: reload option
        }
    }

    func removeObservers() {
        imageData.observer = nil
        downloadFailed.observer = nil
        isLoading.observer = nil
    }

    func abortRequest() {
        imageRequest?.task.cancel()
    }

    deinit {
        removeObservers()
        abortRequest()
    }
}
