//
//  Extension+UIImage.swift
//  PicBucket
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import Foundation

extension UIImage {
    
    func getThumbNail() -> UIImage? {
        var thumbnail: UIImage?
        if let imageData = self.pngData(){
            let options = [
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 100] as CFDictionary // Specify your desired size at kCGImageSourceThumbnailMaxPixelSize. I've specified 100 as per your question
            
            imageData.withUnsafeBytes { ptr in
                guard let bytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    return
                }
                
                if let cfData = CFDataCreate(kCFAllocatorDefault, bytes, imageData.count){
                    let source = CGImageSourceCreateWithData(cfData, nil)!
                    let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
                    thumbnail = UIImage(cgImage: imageReference) // You get your thumbail here
                    
                }
            }
        }
        return thumbnail
    }
}
