//
//  PhotoViewController.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import UIKit
import Combine

class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textLabel: UILabel!

    private let viewModelDetail: PhotoDetailViewModel
    private var viewModel: PhotoViewModel {
        viewModelDetail.photoViewModel
    }

    private var observers = Set<AnyCancellable>()

    init(viewModel: PhotoDetailViewModel) {
        self.viewModelDetail = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureObservers()

        viewModel.downloadImage()

        if viewModelDetail.title.isBlank {
            textLabel.isHidden = true
        } else {
            textLabel.text = viewModelDetail.title
        }
    }

}

//MARK: - Observers
extension PhotoDetailViewController {
    func configureObservers() {

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
            .sink { [weak self] isLoading in
                guard let self = self else { return }

                if isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            }.store(in: &observers)

        viewModel.$downloadFailed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self, let error = error else { return }

                let alert = Alert(title: "Error loading image", message: error.localizedDescription) {
                    self.dismiss(animated: true)
                }

                self.present(alert, animated: true)
            }.store(in: &observers)

    }
}
