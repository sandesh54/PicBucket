//
//  Image.swift
//  PicBucket
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import Foundation
import  GRDB

struct Image: Codable {
    private(set) var id     : Int?
    private(set) var name   : String
    private(set) var data   : Data?
    
    init(name: String, thumbnail data: Data?) {
        self.name = name
        self.data = data
    }
    
    mutating func setData(data: Data) {
        self.data = data
        ImageListTable.update(image: self)
    }
}

extension Image: FetchableRecord, MutablePersistableRecord, Hashable {
    static var databaseTableName: String {
        "bucket_image_list"
    }
}
