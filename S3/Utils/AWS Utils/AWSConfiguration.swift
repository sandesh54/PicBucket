//
//  AWSConfiguration.swift
//  PicBucket
//
//  Created by DSPL on 13/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import Foundation

struct AWSConfiguration {
    
    static func getValueFor(key: AWSKeysIdentifiers ) -> String? {
        guard let plistFilePath     = Bundle.main.path(forResource: "Info", ofType: "plist") else { fatalError("info.plist file does not exist") }
        if let plistData = NSDictionary(contentsOfFile: plistFilePath) as? [String : Any],
            let poolIdentifier =  plistData[key.rawValue] as? String {
            return poolIdentifier
        }
        return nil
    }
    
    
    static func configure() {
        
        guard let accessKey = getValueFor(key: .ACCESS_KEY) else { fatalError( "Access key not found") }
        guard let secretKey = getValueFor(key: .SECRET_KEY)  else { fatalError( "Access key not found") }
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        if let poolIdentifier = getValueFor(key: .POOL_IDENTIFIER) {
            let credentialsProvider1 = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USWest2, identityPoolId: poolIdentifier)
            let configuration1 = AWSServiceConfiguration(region: AWSRegionType.USWest2, credentialsProvider: credentialsProvider1)
            AWSServiceManager.default().defaultServiceConfiguration = configuration1
        } else {
            fatalError("Key not found for configuration")
        }
    }
}
