//
//  UIActivityIndicatorView+Loading.swift
//  ImageGallery
//
//  Created by Paker on 06/05/20.
//

import UIKit

extension UIActivityIndicatorView {
    var isLoading: Bool {
        get {
            isAnimating
        }
        set {
            newValue ? startAnimating() : stopAnimating()
        }
    }
}
