//
//  Table+Image.swift
//  PicBucket
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import Foundation
import GRDB

struct ImageListTable {
    
    static func getImageList() -> [Image]{
        var images: [Image] = []
       
        do {
            try DatabaseManager.sharedDB.read{ db in
                images = try Image.fetchAll(db)
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        return images
    }
    
    static func save(image: Image) -> Bool {
        var tempImg = image
         print(image.name)
        do {
            try DatabaseManager.sharedDB.write { db in
                try tempImg.insert(db)
            }
        } catch let error {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    static func delete(image: Image) -> Bool {
        do {
            try DatabaseManager.sharedDB.write { db in
                _ = try image.delete(db)
            }
        }
        catch let error {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    @discardableResult
    static func update(image: Image) -> Bool {
        do {
           try DatabaseManager.sharedDB.write { db in
            try image.update(db)
           }
        }
        catch let error {
           print(error.localizedDescription)
            return false
        }
        return true
    }
    
    
}
