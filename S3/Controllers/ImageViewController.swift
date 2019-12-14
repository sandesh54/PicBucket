//
//  ImageViewController.swift
//  Cassini
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 DSPL. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
   
    var image: Image?
    private var imageView = UIImageView()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            scrollView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
            ])
            
            scrollView.minimumZoomScale = 0.4
            scrollView.maximumZoomScale = 1.0
            scrollView.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if image != nil {
           showHideActivityIndicator()
            AWSOperationManager.shared.getImage(named: image!.name, progressBlock: {_,_ in }) { data, status in
                if status == .sucess {
                    //Image was downloaded sucess fully
                    self.showHideActivityIndicator()
                    print(data!)
                    if let image = data!.generateImage() {
                        self.imageView.image = image
                        self.imageView.sizeToFit()
                        self.scrollView.contentSize = self.imageView.frame.size
                    }
                } else {
                    print("Fails")
                    self.showHideActivityIndicator()
                }
            }
        }
    }
    
   private func showHideActivityIndicator() {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
