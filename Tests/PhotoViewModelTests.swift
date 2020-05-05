//
//  PhotoViewModel.swift
//  ImageGalleryTests
//
//  Created by Paker on 04/05/20.
//

import XCTest

class PhotoViewModelTests: FlickrTests {

    func testTitle() {
        let photo = TestPhotoModel(id: "49856895562", title: "Title test")

        let viewModel = PhotoDetailViewModel(model: photo, provider: provider)

        XCTAssertEqual(viewModel.title, photo.title.capitalizingFirst)
    }

    func testDownloadImage() {
        let photo = TestPhotoModel(id: "49856895562", title: "Title test")

        let viewModel = GalleryCellViewModel(model: photo, provider: provider)

        let expShowLoading = expectation(description: "Show loading")
        let expHideLoading = expectation(description: "Hide loading")
        let expReceiveImage = expectation(description: "Receive image data")

        XCTAssertFalse(viewModel.isLoading.value, "Should not be loading before request")
        XCTAssertNil(viewModel.downloadFailed.value, "Should not be failed before request")

        viewModel.isLoading.bind { isLoading in
            if isLoading {
                expShowLoading.fulfill()
            } else {
                expHideLoading.fulfill()
            }
        }

        viewModel.downloadFailed.bind { error in
            XCTAssertNil(error, "Should not fail")
        }

        viewModel.imageData.bind { data in
            if data != nil {
                expReceiveImage.fulfill()
            }
        }

        viewModel.downloadImage()

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertFalse(viewModel.isLoading.value, "Should not be loading after finished")
            XCTAssertNotNil(viewModel.imageData.value, "Image data should not be nil")
        }
    }

    func testDownloadImageFail() {
        let photo = TestPhotoModel(id: "0000000000", title: "No image")

        let viewModel = GalleryCellViewModel(model: photo, provider: provider)

        let expShowLoading = expectation(description: "Show loading")
        let expHideLoading = expectation(description: "Hide loading")
        let expDownloadFail = expectation(description: "Download fail")

        XCTAssertFalse(viewModel.isLoading.value, "Should not be loading before request")
        XCTAssertNil(viewModel.downloadFailed.value, "Should not be failed before request")

        viewModel.isLoading.bind { isLoading in
            if isLoading {
                expShowLoading.fulfill()
            } else {
                expHideLoading.fulfill()
            }
        }

        viewModel.downloadFailed.bind { error in
            if error != nil {
                expDownloadFail.fulfill()
            }
        }

        viewModel.imageData.bind { data in
            XCTAssertNil(data, "Should not receive image")
        }

        viewModel.downloadImage()

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertFalse(viewModel.isLoading.value, "Should not be loading after finished")
        }
    }
}
