//
//  GalleryCellView.swift
//  ImageGallery
//
//  Created by Paker on 08/05/20.
//

import SwiftUI
import Combine

//MARK: - Adapter

class GalleryCellAdapter: UICollectionViewCell {
    private var viewController: UIViewController?
    private let cellView = GalleryCellView()

    func configure(viewModel: PhotoViewModel) {
        viewController = UIHostingController(rootView: cellView.environmentObject(viewModel))

        if let view = viewController?.view {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.subviews.first?.removeFromSuperview()
            contentView.addSubview(view)
            view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        }
    }
}

//MARK: - View

fileprivate class DisposableBag {
    var debouncer: AnyCancellable?
    var download: AnyCancellable?
}

struct GalleryCellView: View {
    @EnvironmentObject private var viewModel: PhotoViewModel

    @State private var opacity: Double = 0

    private let debouncer = PassthroughSubject<PhotoViewModel, Never>()

    private var bag = DisposableBag()

    init() {
        bag.debouncer = debouncer
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .map { $0.downloadImage() }
            .assign(to: \.download, on: bag)
    }

    var body: some View {
        ZStack {
            viewModel.imageData.map {
                UIImage(data: $0).map {
                    Image(uiImage: $0)
                        .resizable()
                        .opacity(self.opacity)
                        .onAppear {
                            self.opacity = 0
                            withAnimation {
                                self.opacity = 1
                            }
                    }
                }
            }

            viewModel.downloadFailed.map { _ in
                Button(action: {
                    self.debouncer.send(self.viewModel)
                }) {
                    Image(systemName: "arrow.counterclockwise.icloud.fill")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                    .font(.system(size: 30))
                    .accentColor(.secondary)
            }

            ActivityIndicator(isAnimating: viewModel.isLoading, style: .medium)

        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                self.viewModel.freeMemory()
                self.debouncer.send(self.viewModel)
        }
    }
}
