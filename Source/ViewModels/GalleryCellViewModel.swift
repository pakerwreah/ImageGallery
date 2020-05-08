//
//  GalleryCellViewModel.swift
//  ImageGallery
//
//  Created by Paker on 04/05/20.
//

import Foundation

//FIXME: There is a bug with @Publish + inheritance

//class GalleryCellViewModel: PhotoViewModel {
//    init(model: PhotoModel, provider: PhotosSearchProvider) {
//        super.init(model: model, provider: provider, size: .small)
//    }
//}

class GalleryCellViewModel {
    let photoViewModel: PhotoViewModel

    init(model: PhotoModel, provider: PhotosSearchProvider) {
        photoViewModel = PhotoViewModel(model: model, provider: provider, size: .small)
    }
}
