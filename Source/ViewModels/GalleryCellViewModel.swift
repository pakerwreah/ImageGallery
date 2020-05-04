//
//  GalleryCellViewModel.swift
//  ImageGallery
//
//  Created by Paker on 04/05/20.
//

import Foundation

class GalleryCellViewModel: PhotoViewModel {
    init(model: PhotoModel, provider: PhotosSearchProvider) {
        super.init(model: model, provider: provider, size: .small)
    }
}
