//
//  NetworkProvider.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case notConnected
    case invalidResponse
    case requestCancelled
    case requestFailed(String? = nil)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .notConnected:
            return "Connection failed"
        case .invalidResponse:
            return "Invalid response"
        case .requestCancelled:
            return "Request cancelled"
        case .requestFailed(let reason):
            return reason ?? "Request failed"
        }
    }
}

enum NetworkTimeout: TimeInterval {
    case quick = 5
    case normal = 10
    case long = 15
}

protocol NetworkProvider {
    func request(url: String, timeout: NetworkTimeout) -> AnyPublisher<Data, NetworkError>
}

extension NetworkProvider {
    func request(url: String) -> AnyPublisher<Data, NetworkError> {
        return self.request(url: url, timeout: .quick)
    }
}
