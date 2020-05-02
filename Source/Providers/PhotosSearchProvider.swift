//
//  PhotosSearchProvider.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation

enum ImageSize {
    case small
    case big
}

protocol PhotosSearchProvider {
    // returns itself to chain calls
    @discardableResult func prepare(search: String) -> PhotosSearchProvider
    // returns task if has elements to fetch, nil otherwise
    @discardableResult func fetch(completion: @escaping (Result<[PhotoModel], NetworkError>) -> Void) -> NetworkRequest?
    // download image with given size
    @discardableResult func downloadImage(photo: PhotoModel, size: ImageSize, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkRequest?
}
