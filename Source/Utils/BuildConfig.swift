//
//  BuildConfig.swift
//  ImageGallery
//
//  Created by Paker on 02/05/20.
//

import Foundation

fileprivate func parseConfig<T: Decodable>(filename: String, model: T.Type) -> T {
    let url = Bundle.main.url(forResource: filename, withExtension: "plist")!
    let data = try! Data(contentsOf: url)
    let decoder = PropertyListDecoder()
    return try! decoder.decode(model, from: data)
}

struct FlickrConfig: Decodable {
    private enum CodingKeys: String, CodingKey {
        case apikey
    }

    let apikey: String

    init() {
        self = parseConfig(filename: "Flickr", model: Self.self)
    }
}
