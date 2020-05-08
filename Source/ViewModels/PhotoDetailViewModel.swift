//
//  PhotoDetailViewModel.swift
//  ImageGallery
//
//  Created by Paker on 04/05/20.
//

import Foundation

//FIXME: There is a bug with @Publish + inheritance

//class PhotoDetailViewModel: PhotoViewModel {
//    init(model: PhotoModel, provider: PhotosSearchProvider) {
//        super.init(model: model, provider: provider, size: .big)
//    }
//
//    var title: String {
//        model.title.capitalizingFirst
//    }
//}


class PhotoDetailViewModel {
    let photoViewModel: PhotoViewModel

    init(model: PhotoModel, provider: PhotosSearchProvider) {
        photoViewModel = PhotoViewModel(model: model, provider: provider, size: .big)
    }
    
    var title: String {
        photoViewModel.model.title.capitalizingFirst
    }
}
