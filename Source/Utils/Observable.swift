//
//  Observable.swift
//  ImageGallery
//
//  Created by Paker on 01/05/20.
//

import Foundation

class Observable<T> {
    typealias Observer = ((T) -> Void)

    var observer: Observer?

    init(_ value: T) {
        self.value = value
    }

    var value: T {
        didSet {
            notify()
        }
    }

    func notify() {
        observer?(self.value)
    }

    func bind(on dispatchQueue: DispatchQueue = .main, observer: @escaping Observer) {
        self.observer = { value in
            dispatchQueue.async {
                observer(value)
            }
        }
    }
}
