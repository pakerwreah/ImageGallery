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
    let downloadFailed = Observable<Bool>(false)
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
        downloadFailed.value = false

        // download big photo
        imageRequest = provider.downloadImage(photo: model, size: size) { [weak self] result in
            guard let self = self else { return }

            self.isLoading.value = false

            switch result {
            case .success(let data):
                self.imageData.value = data

            case .failure(.requestCancelled): ()

            default:
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

    func freeMemory() {
        imageData.value = nil
    }

    //MARK: - Presentation

    var title: String {
        model.title.capitalizingFirst
    }
}
