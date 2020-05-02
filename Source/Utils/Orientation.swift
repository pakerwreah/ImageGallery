//
//  Orientation.swift
//  ImageGallery
//
//  Created by Paker on 02/05/20.
//

import UIKit

class Orientation {
    static var isPortrait: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isPortrait ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isPortrait
        }
    }

    static var isLandscape: Bool {
        return !isPortrait
    }
}
