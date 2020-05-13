//
// Created by Paker on 12/05/20.
//

import SwiftUI
import Combine

fileprivate struct Row: Identifiable {
    let id: Int
    let items: [GalleryCellViewModel]
}

fileprivate func cellSizeToFit(listWidth: CGFloat, count: Int, spacing: CGFloat = 10) -> CGFloat {
    let size: CGFloat = listWidth / CGFloat(count)
    let margin: CGFloat = CGFloat(count) * spacing / 2.0
    return size - margin
}

struct GalleryView: View {
    @State private var searchText: String = ""
    @State private var photoDetailPresented = false
    @State private var photoDetail: PhotoDetailViewModel?

    private let columns = 2

    private var rows: [[GalleryCellViewModel]] {
        viewModel.photos.chunked(into: columns)
    }

    @ObservedObject private var viewModel: GalleryViewModel

    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    VStack {
                        SearchBar(text: self.$searchText).onSearch {
                            self.viewModel.removeAll()
                            self.viewModel.searchText = self.searchText
                            self.viewModel.fetchImages()
                        }
                        List(self.rows
                                .enumerated()
                                .map { Row(id: $0.offset, items: $0.element) }) { row in
                            HStack {
                                ForEach(row.items, id: \.photoViewModel.model.id) { cellViewModel in
                                    GalleryCellView(viewModel: cellViewModel)
                                            .frame(height: cellSizeToFit(listWidth: geometry.size.width, count: row.items.count))
                                }
                            }.onAppear {
                                // Infinite scroll: when the grid reaches 8 photos before the end, start fetching the next page
                                if row.id == self.rows.count - 8 {
                                    self.viewModel.fetchImages()
                                }
                            }.onTapGesture {
                                self.photoDetail = self.viewModel.photoDetailViewModel(forItemAt: IndexPath(row: row.id, section: 0))
                                self.photoDetailPresented = true
                            }.sheet(isPresented: self.$photoDetailPresented) {
                                Text(self.photoDetail!.title)
                                // TODO:
                                //present(PhotoDetailViewController(viewModel: photoDetail), animated: true)
                            }
                        }.padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                    }
                            .navigationBarTitle(Text("Image Gallery"))
                            .onAppear {
                                UITableView.appearance().separatorStyle = .none
                            }
                }

                ActivityIndicator(isAnimating: self.viewModel.isLoading, style: .large)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
