//
//  Extension+Data.swift
//  PicBucket
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import Foundation

extension Data {
    
    func generateImage() -> UIImage? {
        if let image = UIImage(data: self) {
            return image
        }
        return nil
    }
    
}
