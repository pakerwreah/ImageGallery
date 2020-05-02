//
//  NetworkProvider.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case connectionFailed
    case invalidResponse
    case requestFailed(String? = nil)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .connectionFailed:
            return "Connection failed"
        case .invalidResponse:
            return "Invalid response"
        case .requestFailed(let reason):
            return reason ?? "Request failed"
        }
    }
}

class NetworkRequest {
    private(set) var task: URLSessionTask

    init(task: URLSessionTask) {
        self.task = task
    }

    func copy(_ request: NetworkRequest) {
        self.task = request.task
    }
}

protocol NetworkProvider {
    @discardableResult func request(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkRequest?
}
