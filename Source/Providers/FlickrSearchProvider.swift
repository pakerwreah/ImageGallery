//
//  FlickrSearchProvider.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation

class FlickrSearchProvider: PhotosSearchProvider {

    private var apikey: String
    private var page = 0
    private var totalPages = 0
    private var search = ""

    private var network: NetworkProvider

    init(apikey: String, networkProvider: NetworkProvider = Network(cachePolicy: .returnCacheDataElseLoad, timeout: .quick)) {
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

    @discardableResult func fetch(completion: @escaping (Result<[PhotoModel], NetworkError>) -> Void) -> NetworkRequest? {
        guard page < totalPages else {
            return nil
        }

        let url = flickrUrl(method: "search", params: ["tags": search, "page": page + 1])

        return network.request(url: url) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                if let sizeResults = try? JSONDecoder().decode(FlickrSearchResults.self, from: data) {
                    let photos = sizeResults.photos
                    self.page = photos.page
                    self.totalPages = photos.pages
                    completion(.success(photos.photo))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    @discardableResult func downloadImage(photo: PhotoModel, size: ImageSize, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkRequest? {

        var request: NetworkRequest? = nil

        request = getSizes(id: photo.id) { result in

            switch result {
            case .success(let sizes):

                // update request reference with new task
                if let sizeRequest = self.downloadSize(sizes: sizes, size: size, completion: completion) {
                    request?.copy(sizeRequest)
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return request
    }

    private func getSizes(id: String, completion: @escaping (Result<[FlickrSizeModel], NetworkError>) -> Void) -> NetworkRequest? {

        let url = flickrUrl(method: "getSizes", params: ["photo_id": id])

        return network.request(url: url) { result in
            switch result {
            case .success(let data):
                if let sizeResults = try? JSONDecoder().decode(FlickrSizeResults.self, from: data) {
                    completion(.success(sizeResults.sizes.size))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func downloadSize(sizes: [FlickrSizeModel], size: ImageSize, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkRequest? {
        let label: String

        switch size {
        case .small:
            label = "Large Square"
        case .big:
            label = "Large"
        }

        if let photo = sizes.first(where: { $0.label == label }) {
            return network.request(url: photo.source, completion: completion)
        } else {
            completion(.failure(.requestFailed("\(label) size not found")))
        }

        return nil
    }

    private func flickrUrl(method: String, params: [String: Any]) -> String {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"

        var queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.\(method)"),
            URLQueryItem(name: "per_page", value: "32"),
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
