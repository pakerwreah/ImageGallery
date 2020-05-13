//
// Created by Paker on 12/05/20.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String

    private var action: (() -> Void)? = nil

    init(text: Binding<String>) {
        _text = text
    }

    private init(text: Binding<String>, action: @escaping () -> Void) {
        _text = text
        self.action = action
    }

    @inlinable func onSearch(perform action: @escaping () -> Void) -> some View {
        SearchBar(text: $text, action: action)
    }

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        private var action: (() -> Void)? = nil

        init(text: Binding<String>, action: (() -> Void)? = nil) {
            _text = text
            self.action = action
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            action?()
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        Coordinator(text: $text, action: action)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}