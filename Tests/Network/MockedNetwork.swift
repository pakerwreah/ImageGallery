//
//  MockedNetwork.swift
//  ImageGalleryTests
//
//  Created by Carlos on 01/05/20.
//

import Foundation

class MockedNetwork: Network {
    private let intercept: (String) -> String?
    
    init(intercept: @escaping (String) -> String?) {
        self.intercept = intercept
    }
    
    override func request(url: String, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkRequest? {

        if let data = intercept(url)?.data(using: .utf8) {
            completion(.success(data))
        } else {
            return super.request(url: url, completion: completion)
        }
        
        return nil
    }
}
