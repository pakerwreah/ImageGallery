//
//  GalleryCell.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import UIKit
import Combine

class GalleryCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!

    private var observers = Set<AnyCancellable>()

    var viewModel: PhotoViewModel? {
        didSet {
            imageView.layer.removeAllAnimations()
            imageView.alpha = 0

            configureObservers()

            viewModel?.downloadImage()
        }
    }

    @IBAction func reload(_ sender: Any) {
        viewModel?.downloadImage()
    }
}

//MARK: - Observers
extension GalleryCell {
    func configureObservers() {
        guard let viewModel = viewModel else { return }

        viewModel.$imageData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageData in
                guard let self = self else { return }

                if let data = imageData, let image = UIImage(data: data) {
                    self.imageView.image = image
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.alpha = 1
                    }
                }
            }.store(in: &observers)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: loadingIndicator)
            .store(in: &observers)

        viewModel.$downloadFailed
            .map { $0 == nil }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, on: reloadButton)
            .store(in: &observers)

    }

    func recycle() {
        observers.removeAll()
        viewModel?.abortRequest()
        viewModel?.freeMemory()
    }
}
