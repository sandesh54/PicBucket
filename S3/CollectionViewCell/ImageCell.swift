//
//  ImageCell.swift
//  S3
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ImageCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        imageView.layer.cornerRadius = 8
    }
    
    private func showHideActivityIndicator() {
        if activityIndicator.isAnimating {
            activityIndicator?.stopAnimating()
        } else {
            activityIndicator?.startAnimating()
        }
    }
    
    func loadCell(with img: Image) {
        var image = img
        if let thumbnailData = image.data {
            imageView.image = UIImage(data: thumbnailData)
        } else {
            showHideActivityIndicator()
            AWSOperationManager.shared.getImage(named: image.name, progressBlock: {_,_ in }) { data, status in
                if status == .sucess {
                    //Image was downloaded sucess fully
                    self.showHideActivityIndicator()
                    print(data!)
                    if let thumbnailImage = data!.generateImage()?.getThumbNail() {
                        print(thumbnailImage.jpegData(compressionQuality: 1.0))
                        self.imageView.image = thumbnailImage
                        if let data = thumbnailImage.jpegData(compressionQuality: 1.0) {
                            image.setData(data: data)
                        }
                    }
                } else {
                    print("Fails")
                    self.showHideActivityIndicator()
                }
            }
            
        }
    }
}
