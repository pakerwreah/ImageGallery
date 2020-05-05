//
//  GalleryViewModelTests.swift
//  ImageGalleryTests
//
//  Created by Paker on 04/05/20.
//

import XCTest

class GalleryViewModelTests: FlickrTests {

    func testSearch() {
        provider.itemsPerPage = 10

        let viewModel = GalleryViewModel(provider: provider)

        let expShowLoading = expectation(description: "Show loading")
        let expHideLoading = expectation(description: "Hide loading")
        let expReceiveItems = expectation(description: "Receive items")

        viewModel.searchText = "kitten"

        XCTAssertFalse(viewModel.isLoading.value, "Should not be loading before request")
        XCTAssertNil(viewModel.requestFailed.value, "Should not be failed before request")

        viewModel.isLoading.bind { isLoading in
            if isLoading {
                expShowLoading.fulfill()
            } else {
                expHideLoading.fulfill()
            }
        }

        viewModel.requestFailed.bind { error in
            XCTAssertNil(error, "Should not fail")
        }

        viewModel.insertedItems.bind { items in
            expReceiveItems.fulfill()
            let itemsPerPage = self.provider.itemsPerPage
            XCTAssertEqual(items.count, itemsPerPage, "Should return \(itemsPerPage) items per page")
        }

        viewModel.fetchImages()

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertFalse(viewModel.isLoading.value, "Should not be loading after finished")
        }
    }

}