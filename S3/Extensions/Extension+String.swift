//
//  Extension+String.swift
//  S3
//
//  Created by DSPL on 14/12/19.
//  Copyright © 2019 Sandesh. All rights reserved.
//

import Foundation

extension String {
    public init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
    }
}
