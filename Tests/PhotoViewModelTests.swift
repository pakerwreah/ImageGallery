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

        let viewModel = GalleryCellViewModel(model: photo, provider: provider).photoViewModel

        let expShowLoading = expectation(description: "Show loading")
        let expHideLoading = expectation(description: "Hide loading")
        let expReceiveImage = expectation(description: "Receive image data")

        XCTAssertFalse(viewModel.isLoading, "Should not be loading before request")
        XCTAssertNil(viewModel.downloadFailed, "Should not be failed before request")

        viewModel.$isLoading.dropFirst().sink { isLoading in
            if isLoading {
                expShowLoading.fulfill()
            } else {
                expHideLoading.fulfill()
            }
        }.store(in: &observable)

        viewModel.$downloadFailed.sink { error in
            XCTAssertNil(error, "Should not fail")
        }.store(in: &observable)

        viewModel.$imageData.sink { data in
            if data != nil {
                expReceiveImage.fulfill()
            }
        }.store(in: &observable)

        viewModel.downloadImage()

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertFalse(viewModel.isLoading, "Should not be loading after finished")
            XCTAssertNotNil(viewModel.imageData, "Image data should not be nil")
        }
    }

    func testDownloadImageFail() {
        let photo = TestPhotoModel(id: "0000000000", title: "No image")

        let viewModel = GalleryCellViewModel(model: photo, provider: provider).photoViewModel

        let expShowLoading = expectation(description: "Show loading")
        let expHideLoading = expectation(description: "Hide loading")
        let expDownloadFail = expectation(description: "Download fail")

        XCTAssertFalse(viewModel.isLoading, "Should not be loading before request")
        XCTAssertNil(viewModel.downloadFailed, "Should not be failed before request")

        viewModel.$isLoading.dropFirst().sink { isLoading in
            if isLoading {
                expShowLoading.fulfill()
            } else {
                expHideLoading.fulfill()
            }
        }.store(in: &observable)

        viewModel.$downloadFailed.sink { error in
            if error != nil {
                expDownloadFail.fulfill()
            }
        }.store(in: &observable)

        viewModel.$imageData.sink { data in
            XCTAssertNil(data, "Should not receive image")
        }.store(in: &observable)

        viewModel.downloadImage()

        waitForExpectations(timeout: NetworkTimeout.quick.rawValue) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertFalse(viewModel.isLoading, "Should not be loading after finished")
        }
    }
}
