//
//  AnyPublisher+Helpers.swift
//  ImageGallery
//
//  Created by Paker on 07/05/20.
//

import Foundation
import Combine

extension AnyPublisher {
    static func just(_ output: Output) -> Self {
        Just(output).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> Self {
        Fail(error: error).eraseToAnyPublisher()
    }
}
