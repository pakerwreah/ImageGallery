//
//  PhotosSearchProvider.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation
import Combine

enum ImageSize {
    case small
    case big
}

protocol PhotosSearchProvider {
    // returns itself to chain calls
    @discardableResult func prepare(search: String) -> PhotosSearchProvider
    // returns task if has elements to fetch, nil otherwise
    func fetch() -> AnyPublisher<[PhotoModel], NetworkError>
    // download image with given size
    func downloadImage(photo: PhotoModel, size: ImageSize) -> AnyPublisher<Data, NetworkError>
}
