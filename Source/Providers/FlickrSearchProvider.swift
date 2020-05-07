//
//  FlickrSearchProvider.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation
import Combine

class FlickrSearchProvider: PhotosSearchProvider {

    private var apikey: String
    private var page = 0
    private var totalPages = 0
    private var search = ""

    var itemsPerPage = 32

    private var network: NetworkProvider

    init(apikey: String, networkProvider: NetworkProvider = CachedNetworkProvider(cachePolicy: .returnCacheDataElseLoad, timeout: .quick)) {
        self.apikey = apikey
        self.network = networkProvider
    }

    func prepare(search term: String) -> PhotosSearchProvider {
        page = 0
        totalPages = 1
        search = term
        // returns itself to chain calls
        return self
    }

    func fetch() -> AnyPublisher<[PhotoModel], NetworkError> {
        guard page < totalPages else {
            return .just([])
        }

        let url = flickrUrl(method: "search", params: ["tags": search, "page": page + 1, "per_page": itemsPerPage])

        return network.request(url: url)
            .decode(type: FlickrSearchResults.self, decoder: JSONDecoder())
            .map { [weak self] sizeResults in
                guard let self = self else { return [] }

                let photos = sizeResults.photos
                self.page = photos.page
                self.totalPages = photos.pages

                return photos.photo
            }.mapError { error in
                error as? NetworkError ?? .invalidResponse
            }.eraseToAnyPublisher()
    }

    func downloadImage(photo: PhotoModel, size: ImageSize) -> AnyPublisher<Data, NetworkError> {

        let url = flickrUrl(method: "getSizes", params: ["photo_id": photo.id])

        let label: String

        switch size {
        case .small:
            label = "Large Square"
        case .big:
            label = "Large"
        }
        
        let network = self.network

        return network.request(url: url)
            .decode(type: FlickrSizeResults.self, decoder: JSONDecoder())
            .map { $0.sizes.size }
            .tryMap { sizes in
                if let photo = sizes.first(where: { $0.label == label }) {
                    return photo.source
                } else {
                    throw NetworkError.requestFailed("\(label) size not found")
                }
            }
            .mapError { $0 as? NetworkError ?? .invalidResponse }
            .flatMap { network.request(url: $0) }
            .eraseToAnyPublisher()
    }

    private func flickrUrl(method: String, params: [String: Any]) -> String {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"

        var queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.\(method)"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "api_key", value: apikey)
        ]

        queryItems.append(contentsOf: params.map {
            URLQueryItem(name: $0.key, value: String(describing: $0.value))
        })

        // avoid changing url for the same parameters (cache related)
        components.queryItems = queryItems.sorted(by: { $0.name < $1.name })

        return components.url?.absoluteString ?? ""
    }
}


//MARK: - Private models

fileprivate struct FlickrPhotoModel: PhotoModel, Codable {
    var id: String
    var title: String
}

fileprivate struct FlickrPhotosModel: Codable {
    let page: Int
    let pages: Int
    let photo: [FlickrPhotoModel]
}

fileprivate struct FlickrSearchResults: Codable {
    let stat: String
    let photos: FlickrPhotosModel
}

fileprivate struct FlickrSizeModel: Codable {
    let label: String
    let source: String
}

fileprivate struct FlickrSizesModel: Codable {
    let size: [FlickrSizeModel]
}

fileprivate struct FlickrSizeResults: Codable {
    let stat: String
    let sizes: FlickrSizesModel
}
