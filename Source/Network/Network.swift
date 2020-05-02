//
//  Network.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation

enum NetworkTimeout: TimeInterval {
    case quick = 10
    case normal = 30
    case long = 60
}

class Network: NetworkProvider {
    private let cachePolicy: URLRequest.CachePolicy
    private let timeoutInterval: NetworkTimeout

    init(cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeout: NetworkTimeout = .normal) {
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeout
    }

    func request(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkRequest? {

        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return nil
        }

        let request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval.rawValue)

        if Network.isConnected {
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    200 ..< 300 ~= httpResponse.statusCode {
                    completion(.success(data))
                } else {
                    completion(.failure(.requestFailed(error?.localizedDescription)))
                }
            }

            task.resume()

            return NetworkRequest(task: task)

        } else if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            completion(.success(cachedResponse.data))

        } else {
            completion(.failure(.connectionFailed))
        }

        return nil
    }
}
