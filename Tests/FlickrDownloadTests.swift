//
//  FlickrDownloadTests.swift
//  ImageGalleryTests
//
//  Created by Carlos on 01/05/20.
//

import XCTest

class FlickrDownloadTests: FlickrTests {

    func testDownloadImage() {

        let network = MockedNetwork { url -> String? in

            if url.contains("method=flickr.photos.getSizes") {
                return """
                            {
                                "sizes": {
                                    "canblog": 0,
                                    "canprint": 0,
                                    "candownload": 1,
                                    "size": [
                                        {
                                            "label": "Large Square",
                                            "width": 150,
                                            "height": 150,
                                            "source": "https://live.staticflickr.com/65535/49635266588_6a976f872f_q.jpg",
                                            "url": "https://www.flickr.com/photos/33244024@N06/49635266588/sizes/q/",
                                            "media": "photo"
                                        },
                                        {
                                            "label": "Large",
                                            "width": 1024,
                                            "height": 684,
                                            "source": "https://live.staticflickr.com/65535/49635266588_6a976f872f_b.jpg",
                                            "url": "https://www.flickr.com/photos/33244024@N06/49635266588/sizes/l/",
                                            "media": "photo"
                                        }
                                    ]
                                },
                                "stat": "ok"
                            }
                       """
            }

            return nil
        }

        let provider = FlickrSearchProvider(apikey: apikey, networkProvider: network)

        let photo = TestPhotoModel(id: "49635266588", title: "")

        let exp_small = expectation(description: "Small image downloaded")

        provider.downloadImage(photo: photo, size: .small)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: ()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
                exp_small.fulfill()
            }, receiveValue: { _ in })
            .store(in: &disposables)

        let exp_big = expectation(description: "Big image downloaded")

        provider.downloadImage(photo: photo, size: .big)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: ()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
                exp_big.fulfill()
            }, receiveValue: { _ in })
            .store(in: &disposables)

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testSizeNotFound() {

        let network = MockedNetwork { url -> String? in
            if url.contains("method=flickr.photos.getSizes") {
                return """
                        {
                            "sizes": {
                                "canblog": 0,
                                "canprint": 0,
                                "candownload": 1,
                                "size": [
                                    {
                                        "label": "Square",
                                        "width": 75,
                                        "height": 75,
                                        "source": "https://live.staticflickr.com/65535/49635266588_6a976f872f_s.jpg",
                                        "url": "https://www.flickr.com/photos/33244024@N06/49635266588/sizes/sq/",
                                        "media": "photo"
                                    }
                                ]
                            },
                            "stat": "ok"
                        }
                   """
            }

            return nil
        }

        let provider = FlickrSearchProvider(apikey: apikey, networkProvider: network)

        let photo = TestPhotoModel(id: "49635266588", title: "")

        let exp_small = expectation(description: "Small image not found")

        provider.downloadImage(photo: photo, size: .small)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    XCTFail("Small image size does not exist")
                case .failure: ()
                }
                exp_small.fulfill()
            }, receiveValue: { _ in })
            .store(in: &disposables)

        let exp_big = expectation(description: "Big image not found")

        provider.downloadImage(photo: photo, size: .big)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    XCTFail("Big image size does not exist")
                case .failure: ()
                }
                exp_big.fulfill()
            }, receiveValue: { _ in })
            .store(in: &disposables)

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testImageNotFound() {

        let network = MockedNetwork { url -> String? in
            if url.contains("method=flickr.photos.getSizes") {
                return """
                        {
                            "sizes": {
                                "canblog": 0,
                                "canprint": 0,
                                "candownload": 1,
                                "size": [
                                    {
                                        "label": "Large",
                                        "width": 1024,
                                        "height": 684,
                                        "source": "https://live.staticflickr.com/65535/49635266588_6a976f872f_invalid.jpg",
                                        "url": "https://www.flickr.com/photos/33244024@N06/49635266588/sizes/l/",
                                        "media": "photo"
                                    }
                                ]
                            },
                            "stat": "ok"
                        }
                   """
            }

            return nil
        }

        let provider = FlickrSearchProvider(apikey: apikey, networkProvider: network)

        let photo = TestPhotoModel(id: "49635266588", title: "")

        let exp = expectation(description: "Image not found")

        provider.downloadImage(photo: photo, size: .big)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    XCTFail("Image does not exists")
                case .failure: ()
                }
                exp.fulfill()
            }, receiveValue: { _ in })
            .store(in: &disposables)

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

}
