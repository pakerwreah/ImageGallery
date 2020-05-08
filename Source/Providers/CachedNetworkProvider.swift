//
//  Network.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation
import Combine

class CachedNetworkProvider: NetworkProvider {
    private let cachePolicy: URLRequest.CachePolicy
    private let timeoutInterval: NetworkTimeout

    init(cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeout: NetworkTimeout = .normal) {
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeout
    }

    func request(url: String, timeout: NetworkTimeout) -> AnyPublisher<Data, NetworkError> {
        guard let url = URL(string: url) else {
            return .fail(.invalidURL)
        }

        let request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval.rawValue)

        if isConnected {
            return URLSession.shared.dataTaskPublisher(for: request)
                .first()
                .tryMap { data, response in
                    if let httpResponse = response as? HTTPURLResponse,
                        200 ..< 300 ~= httpResponse.statusCode {
                        return data
                    } else {
                        throw NetworkError.requestFailed()
                    }
                }
                .mapError { error in
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        return .requestCancelled
                    } else {
                        return error as? NetworkError ?? .requestFailed(error.localizedDescription)
                    }
                }.eraseToAnyPublisher()
        } else if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            return .just(cachedResponse.data)
        } else {
            return .fail(.notConnected)
        }
    }
}
