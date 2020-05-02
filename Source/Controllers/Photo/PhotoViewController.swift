//
//  PhotoViewController.swift
//  ImageGallery
//
//  Created by Carlos on 01/05/20.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!

    private let image: UIImage
    private let text: String

    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        textLabel.text = text

        textLabel.isHidden = text.isBlank
    }

}
