//
//  PhotoViewerViewController.swift
//  Messenger
//
//  Created by Katharos on 16/11/2022.
//

import UIKit
import SDWebImage

final class PhotoViewerViewController: UIViewController {
    
    private let url: URL
    
    init(with url: URL) {
        self.url = url
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo"
        tabBarController?.tabBar.isHidden = true
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.sd_setImage(with: url)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
}
