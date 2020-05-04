//
//  GalleryCell.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import UIKit

class GalleryCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!

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

        viewModel.imageData.bind { [weak self] imageData in
            guard let self = self else { return }

            if let data = imageData, let image = UIImage(data: data) {
                self.imageView.image = image
                UIView.animate(withDuration: 0.3) {
                    self.imageView.alpha = 1
                }
            }
        }

        viewModel.isLoading.bind { [weak self] isLoading in
            guard let self = self else { return }

            if isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }

        viewModel.downloadFailed.bind { [weak self] error in
            guard let self = self else { return }

            self.reloadButton.isHidden = error == nil
        }

    }
}
