//
//  FlickrTests.swift
//  ImageGalleryTests
//
//  Created by Carlos on 01/05/20.
//

import XCTest
import Combine

class FlickrTests: XCTestCase {

    let apikey = FlickrConfig().apikey

    var provider: FlickrSearchProvider!
    
    var disposables = Set<AnyCancellable>()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        provider = FlickrSearchProvider(apikey: apikey)

        URLCache.shared.removeAllCachedResponses()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}
