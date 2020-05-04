//
//  PhotoDetailViewModel.swift
//  ImageGallery
//
//  Created by Paker on 04/05/20.
//

import Foundation

class PhotoDetailViewModel: PhotoViewModel {
    init(model: PhotoModel, provider: PhotosSearchProvider) {
        super.init(model: model, provider: provider, size: .big)
    }
    
    var title: String {
        model.title.capitalizingFirst
    }
}
