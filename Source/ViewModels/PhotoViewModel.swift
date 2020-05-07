//
//  PhotoViewModel.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation
import Combine

class PhotoViewModel {
    private let provider: PhotosSearchProvider
    private var imageRequest: AnyCancellable?
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

        imageRequest = provider.downloadImage(photo: model, size: size)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }

                switch completion {
                case .failure(.requestCancelled): ()

                case .failure(let error):
                    self.isLoading = false
                    self.downloadFailed = error

                case .finished:
                    self.isLoading = false
                    break
                }
            }, receiveValue: { [weak self] data in
                self?.imageData = data
            })
    }

    func abortRequest() {
        imageRequest?.cancel()
    }

    func freeMemory() {
        imageData = nil
    }
}
