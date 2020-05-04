//
//  PhotoViewModel.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation

class PhotoViewModel {
    private let provider: PhotosSearchProvider
    private var imageRequest: NetworkRequest?
    private let size: ImageSize

    let model: PhotoModel

    let imageData = Observable<Data?>(nil)
    let downloadFailed = Observable<NetworkError?>(nil)
    let isLoading = Observable<Bool>(false)

    init(model: PhotoModel, provider: PhotosSearchProvider, size: ImageSize) {
        self.model = model
        self.provider = provider
        self.size = size
    }

    deinit {
        removeObservers()
        abortRequest()
    }

    func downloadImage() {
        isLoading.value = true
        downloadFailed.value = nil
        imageData.value = nil

        imageRequest = provider.downloadImage(photo: model, size: size) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                self.isLoading.value = false
                self.imageData.value = data

            case .failure(.requestCancelled): ()

            case .failure(let error):
                self.isLoading.value = false
                self.downloadFailed.value = error
            }
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

    func freeMemory() {
        imageData.value = nil
    }
}
