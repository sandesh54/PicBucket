//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AWSS3

/// The class confirming to AWSS3Behavior which uses an instance of the AWSS3 to perform its methods. This class acts
/// as a wrapper to expose AWSS3 functionality through an instance over a singleton, and allows for mocking in unit
/// tests. The methods contain no other logic other than calling the same method using the AWSS3 instance.
class AWSS3Adapter: AWSS3Behavior {
    let awsS3: AWSS3

    init(_ awsS3: AWSS3) {
        self.awsS3 = awsS3
    }

    public func listObjectsV2(_ request: AWSS3ListObjectsV2Request) -> AWSTask<AWSS3ListObjectsV2Output> {
        return awsS3.listObjectsV2(request)
    }

    public func deleteObject(_ request: AWSS3DeleteObjectRequest) -> AWSTask<AWSS3DeleteObjectOutput> {
        return awsS3.deleteObject(request)
    }

    public func getS3() -> AWSS3 {
        return awsS3
    }
}
