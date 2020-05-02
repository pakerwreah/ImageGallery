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
    private let provider: PhotosSearchProvider
    private var photos: [GalleryCellViewModel] = []
    private var fetchRequest: NetworkRequest?
    private var isLoading = false

    init(provider: PhotosSearchProvider) {
        self.provider = provider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Image Gallery"

        URLCache.shared.removeAllCachedResponses() // FIXME: remove

        // force capitalization off beacause it's not respecting xib config
        searchBar.autocapitalizationType = .none

        // register cell layout to use in the collection view
        grid.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let gridLayout = grid.collectionViewLayout as? UICollectionViewFlowLayout {
            // calculates the size to fit 2 elements per row
            let size = grid.bounds.width / 2 - 5
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
        fetchRequest?.task.cancel()
    }

    private func fetchImages() {
        if !isLoading {
            isLoading = true

            // if it is the first fetch, show loading indicator
            if photos.isEmpty {
                loadingIndicator?.startAnimating()
            }

            fetchRequest = provider.fetch { [weak self] result in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    switch result {
                    case .success(let photos):
                        // append the photos to the end of the collection view
                        self.photos.append(contentsOf: photos.map { GalleryCellViewModel(model: $0, provider: self.provider) })
                        let total = self.photos.count
                        if total == 0 {
                            self.grid.reloadData()
                        } else {
                            let range = max(total - photos.count, 0) ..< total
                            self.grid.insertItems(at: range.map { IndexPath(row: $0, section: 0) })
                        }

                    case .failure(let error):
                        self.present(Alert(title: "Error loading images", message: error.localizedDescription), animated: true)
                    }

                    // reset the flag and stop indicator
                    self.isLoading = false
                    self.loadingIndicator?.stopAnimating()
                }

                // if there is nothing to fetch, reset the flag and stop indicator
                if self.fetchRequest == nil {
                    self.isLoading = false
                    self.loadingIndicator?.stopAnimating()
                }
            }
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
            photos.removeAll()
            grid.reloadData()
            // scroll to top
            grid.contentOffset = .zero
            // update text in the photo provider
            provider.prepare(search: text)
            // search images
            fetchImages()
        }
    }
}

//MARK: - CollectionView Delegate
extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if !isLoading {
            isLoading = true

            let photo = PhotoViewModel(model: photos[indexPath.row].model, provider: provider)

            // TODO: convert to MVVM
            // download big photo
            provider.downloadImage(photo: photos[indexPath.row].model, size: .big) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        // show big photo in fullscreen
                        if let image = UIImage(data: data) {
                            self.present(PhotoViewController(image: image, text: photo.title), animated: true)
                        }
                    case .failure(let error):
                        self.present(Alert(title: "Error loading image", message: error.localizedDescription), animated: true)
                    }
                }
                self.isLoading = false
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Infinite scroll: when the grid reaches 8 photos before the end, start fetching the next page
        if indexPath.row == photos.count - 8 {
            fetchImages()
        }
    }
}

//MARK: - Data Source
extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell

        cell.viewModel = photos[indexPath.row]

        return cell
    }
}
