//
//  GalleryCell.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import UIKit

class GalleryCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView! // TODO: connect to xib

    var viewModel: GalleryCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                viewModel.removeObservers()
                viewModel.abortRequest()

                imageView.layer.removeAllAnimations()
                imageView.alpha = 0

                viewModel.imageData.bind { value in
                    if let data = value, let image = UIImage(data: data) {
                        self.imageView.image = image
                        UIView.animate(withDuration: 0.3) {
                            self.imageView.alpha = 1
                        }
                    }
                }
                
                // TODO: isLoading observer
                // TODO: downloadFailed observer

                viewModel.downloadImage()
            }
        }
    }
}
