//
//  PhotoViewModel.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation

class PhotoViewModel {
    private let model: PhotoModel
    private let provider: PhotosSearchProvider
    private var imageRequest: NetworkRequest?

    init(model: PhotoModel, provider: PhotosSearchProvider) {
        self.model = model
        self.provider = provider
    }

    func downloadImage(completion: @escaping (Result<Data, NetworkError>) -> Void) {
        // download big photo
        imageRequest = provider.downloadImage(photo: model, size: .big, completion: completion)
    }

    func abortRequest() {
        imageRequest?.task.cancel()
        imageRequest = nil
    }
    
    deinit {
        abortRequest()
    }

    //MARK: - Model Data

    var title: String {
        model.title.capitalizingFirst
    }
}
