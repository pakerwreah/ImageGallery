//
//  GalleryViewController.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import UIKit

class GalleryViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var grid: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    private let cellIdentifier = "GalleryCell"
    private let viewModel: GalleryViewModel

    init(provider: PhotosSearchProvider) {
        viewModel = GalleryViewModel(provider: provider)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Image Gallery"

        // force capitalization off beacause it's not respecting xib config
        searchBar.autocapitalizationType = .none

        // register cell layout to use in the collection view
        grid.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)

        configureObservers()
    }

    private func cellSizeToFit(count: Int, spacing: CGFloat) -> CGFloat {
        let size: CGFloat = grid.bounds.width / CGFloat(count)
        let margin: CGFloat = CGFloat(count) * spacing / 2.0
        return size - margin
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let gridLayout = grid.collectionViewLayout as? UICollectionViewFlowLayout {
            // calculates the size to fit elements in row
            let count = Orientation.isPortrait ? 2 : 4
            let size = cellSizeToFit(count: count, spacing: 5)
            gridLayout.itemSize = CGSize(width: size, height: size)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // when screen rotates, force the collection view to recalculate cells sizes
        coordinator.animate(alongsideTransition: { _ in
            self.grid.collectionViewLayout.invalidateLayout()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // abort current fetching if exists
        viewModel.abortRequest()
    }

}

//MARK: - Observers
extension GalleryViewController {
    func configureObservers() {

        viewModel.isLoading.bind { value in
            // if it is the first fetch, show loading indicator
            if value, self.viewModel.photos.isEmpty {
                self.loadingIndicator?.startAnimating()
            } else {
                self.loadingIndicator?.stopAnimating()
            }
        }

        viewModel.insertedItems.bind { value in
            if !value.isEmpty {
                self.grid.insertItems(at: value)
            }
        }

        viewModel.requestFailed.bind { value in
            self.present(Alert(title: "Error loading images", message: value), animated: true)
        }
    }

}

//MARK: - TextField Delegate
extension GalleryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isBlank {
            // hide keyboard
            view.endEditing(true)
            // remove all items
            viewModel.photos.removeAll()
            // reload grid
            grid.reloadData()
            // scroll to top
            grid.contentOffset = .zero
            // update text to search
            viewModel.searchText = text
            // search images
            viewModel.fetchImages()
        }
    }
}

//MARK: - CollectionView Delegate
extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        if !isLoading {
//            isLoading = true
//
//            let photo = PhotoViewModel(model: photos[indexPath.row].model, provider: provider)
//
//            // TODO: convert to MVVM
//            // download big photo
//            provider.downloadImage(photo: photos[indexPath.row].model, size: .big) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let data):
//                        // show big photo in fullscreen
//                        if let image = UIImage(data: data) {
//                            self.present(PhotoViewController(image: image, text: photo.title), animated: true)
//                        }
//                    case .failure(let error):
//                        self.present(Alert(title: "Error loading image", message: error.localizedDescription), animated: true)
//                    }
//                }
//                self.isLoading = false
//            }
//        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Infinite scroll: when the grid reaches 8 photos before the end, start fetching the next page
        if indexPath.row == viewModel.photos.count - 8 {
            viewModel.fetchImages()
        }
    }
}

//MARK: - Data Source
extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell

        cell.viewModel = viewModel.photos[indexPath.row]

        return cell
    }
}
