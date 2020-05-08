//
//  StringExtension.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import Foundation

extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var capitalizingFirst: String {
        prefix(1).capitalized + dropFirst()
    }
}
