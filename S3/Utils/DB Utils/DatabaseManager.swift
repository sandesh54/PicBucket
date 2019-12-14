//
//  DatabaseManager.swift
//  fmcgsalesrep
//
//  Created by DSPL on 15/11/19.
//  Copyright © 2019 DSPL. All rights reserved.
//

import Foundation
import GRDB

class DatabaseManager {
    
    static var sharedDB: DatabaseQueue  {
       let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        guard let dbQueue = try? DatabaseQueue(path: path + "/PicBucket.sqlite3") else {
            fatalError("Unable to open database queue")
        }
        
        
        do {
            try migrator.migrate(dbQueue,upTo: "v1")
        } catch let errror {
            print(errror.localizedDescription)
        }
        return dbQueue
    }
    
   
    
    
    static private var migrator: DatabaseMigrator {
        
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1") { db in
            
            //MARK:- Tables to store data fetched from server
            
            try db.create(table: "bucket_image_list",ifNotExists: true) { table in
                table.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: true)
                table.column("name", .text).unique()
                table.column("data", .blob)
            }
        }
        return migrator
    }
    
    

  
}




