//
//  GalleryViewController.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import UIKit
import Combine

class GalleryViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var grid: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    private var observers = Set<AnyCancellable>()

    private let cellIdentifier = "GalleryCell"
    private let viewModel: GalleryViewModel

    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel

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
        grid.register(GalleryCellAdapter.self, forCellWithReuseIdentifier: cellIdentifier)

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

        viewModel.$photos
            .filter { $0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                if let grid = self?.grid {
                    grid.reloadData()
                    grid.contentOffset = .zero
                }
            }.store(in: &observers)

        viewModel.$isLoading
            .combineLatest(viewModel.$photos)
            .map { $0.0 && $0.1.isEmpty }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: loadingIndicator)
            .store(in: &observers)

        viewModel.insertedIndexes
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.grid.insertItems(at: items)
            }.store(in: &observers)

        viewModel.$requestFailed
            .compactMap { $0?.localizedDescription }
            .map { Alert(title: "Error loading images", message: $0) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                self?.present(alert, animated: true)
            }.store(in: &observers)

    }
}

//MARK: - TextField Delegate
extension GalleryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isBlank {
            // hide keyboard
            view.endEditing(true)
            // remove all items
            viewModel.removeAll()
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

        let photoDetail = viewModel.photoDetailViewModel(forItemAt: indexPath)

        present(PhotoDetailViewController(viewModel: photoDetail), animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Infinite scroll: when the grid reaches 8 photos before the end, start fetching the next page
        if indexPath.row == viewModel.photos.count - 8 {
            viewModel.fetchImages()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let cell = cell as? GalleryCell {
            cell.recycle()
        }

    }
}

//MARK: - Data Source
extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCellAdapter

        cell.configure(viewModel: viewModel.photos[indexPath.row].photoViewModel)

        return cell
    }
}
