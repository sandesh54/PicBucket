//
//  AWSOperationManager.swift
//  PicBucket
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import UIKit
struct AWSOperationManager {
    
    enum AWSOperationStatus {
        case sucess
        case failure
    }
    
    typealias ProgressBlock = (AWSS3TransferUtilityTask, Progress) -> Void
    typealias CompletionHandler = (AWSOperationStatus) -> Void
    typealias DownloadCompletionHandler = (Data?, AWSOperationStatus) -> Void
    typealias DeleteCompletionHandler = (AWSOperationStatus) -> Void
    
    
    static let shared = AWSOperationManager()
    private init() { }
    
    func saveImage(data: Data, progressBlock:@escaping ProgressBlock, completionHandler:@escaping CompletionHandler ) {
        let uniqueImageName = ProcessInfo.processInfo.globallyUniqueString
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { task, progress in
            DispatchQueue.main.async {
                progressBlock(task, progress)
            }
        }
        
        let handler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { task, error in
            DispatchQueue.main.async {
                if error != nil {
                    completionHandler(.failure)
                } else {
                    let thumbnailData = data.generateImage()?.getThumbNail()?.jpegData(compressionQuality: 1.0)
                    if ImageListTable.save(image: Image(name: uniqueImageName, thumbnail: thumbnailData)) {
                        completionHandler(.sucess)
                    }
                }
            }
        }
        guard  let bucketName = AWSConfiguration.getValueFor(key: .S3_BUCKET) else { fatalError( "Bucket name not found") }
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(data,
                                   bucket: bucketName,
                                   key: uniqueImageName,
                                   contentType: "image/jpeg",
                                   expression: expression,
                                   completionHandler: handler)
    }
    
    func getImage(named imageName: String,progressBlock:@escaping ProgressBlock, completionHandler:@escaping DownloadCompletionHandler) {
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = { task , progress in
            DispatchQueue.main.async {
                progressBlock(task, progress)
            }
        }
        
        let handler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = { (task, location, data, error) -> Void in
            DispatchQueue.main.async {
                if error != nil {
                    print(error.debugDescription)
                    completionHandler(nil, .failure)
                } else {
                    completionHandler(data, .sucess)
                }
            }
        }
        
        guard  let bucketName = AWSConfiguration.getValueFor(key: .S3_BUCKET) else { fatalError( "Bucket name not found") }
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(fromBucket: bucketName,
                                     key: imageName,
                                     expression: expression,
                                     completionHandler: handler)
    }
    
    func deleteImage(named imageName: String, completionHandler:@escaping DeleteCompletionHandler) {
        
        guard  let bucketName = AWSConfiguration.getValueFor(key: .S3_BUCKET) else { fatalError( "Bucket name not found") }
        let s3 = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()!
        deleteObjectRequest.bucket = bucketName
        deleteObjectRequest.key = imageName
        
        s3.deleteObject(deleteObjectRequest).continueWith { task in
            DispatchQueue.main.async {
                if task.error == nil {
                    completionHandler(.sucess)
                } else {
                    completionHandler(.failure)
                }
            }
            return nil
        }
        
    }
}
