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

    @Published private(set) var imageData: Data?
    @Published private(set) var downloadFailed: NetworkError?
    @Published private(set) var isLoading = false

    init(model: PhotoModel, provider: PhotosSearchProvider, size: ImageSize) {
        self.model = model
        self.provider = provider
        self.size = size
    }

    deinit {
        abortRequest()
    }

    func downloadImage() {
        isLoading = true
        downloadFailed = nil
        imageData = nil

        imageRequest = provider.downloadImage(photo: model, size: size) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                self.isLoading = false
                self.imageData = data

            case .failure(.requestCancelled): ()

            case .failure(let error):
                self.isLoading = false
                self.downloadFailed = error
            }
        }
    }

    func abortRequest() {
        imageRequest?.task.cancel()
    }

    func freeMemory() {
        imageData = nil
    }
}
