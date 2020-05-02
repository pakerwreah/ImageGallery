//
//  FlickrSearchTests.swift
//  ImageGalleryTests
//
//  Created by Carlos on 01/05/20.
//

import XCTest

class FlickrSearchTests: FlickrTests {

    func testSearch() {

        let exp = expectation(description: "Request success")

        provider.prepare(search: "kitten").fetch { result in
            switch result {
            case .success(_): ()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testSearchEmptyText() {

        let exp = expectation(description: "Request fail")

        provider.prepare(search: "").fetch { result in
            switch result {
            case .success(_):
                XCTFail("Empty text")
            case .failure(_): ()
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testSearchInvalidResponse() {

        let network = MockedNetwork { url -> String? in
            """
                {
                    "notvalid": "this is not a valid response"
                }
            """
        }

        let provider = FlickrSearchProvider(apikey: apikey, networkProvider: network)

        let exp = expectation(description: "Request fail")

        provider.prepare(search: "kitten").fetch { result in
            switch result {
            case .success(_):
                XCTFail("Invalid response")
            case .failure(_): ()
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: NetworkTimeout.normal.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

}
