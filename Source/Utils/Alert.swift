//
//  Alert.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import UIKit

class Alert: UIAlertController {
    convenience init(title: String?, message: String?, completion: (() -> Void)? = nil) {
        self.init(title: title, message: message, preferredStyle: .alert)
        addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
    }
}
