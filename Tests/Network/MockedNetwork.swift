//
//  MockedNetwork.swift
//  ImageGalleryTests
//
//  Created by Carlos on 01/05/20.
//

import Foundation
import Combine

class MockedNetwork: CachedNetworkProvider {
    private let intercept: (String) -> String?
    
    init(intercept: @escaping (String) -> String?) {
        self.intercept = intercept
    }
    
    override func request(url: String, timeout: NetworkTimeout) -> AnyPublisher<Data, NetworkError> {

        if let data = intercept(url)?.data(using: .utf8) {
            return .just(data)
        } else {
            return super.request(url: url, timeout: timeout)
        }
    }
}
