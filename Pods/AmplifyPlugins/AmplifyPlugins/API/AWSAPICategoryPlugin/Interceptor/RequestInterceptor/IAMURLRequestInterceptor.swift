//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore
import Foundation
import AWSCore
import AWSMobileClient

struct IAMURLRequestInterceptor: URLRequestInterceptor {
    let iamCredentialsProvider: IAMCredentialsProvider
    let region: AWSRegionType
    let endpointType: AWSAPICategoryPluginEndpointType

    init(iamCredentialsProvider: IAMCredentialsProvider,
         region: AWSRegionType,
         endpointType: AWSAPICategoryPluginEndpointType) {
        self.iamCredentialsProvider = iamCredentialsProvider
        self.region = region
        self.endpointType = endpointType
    }

    func intercept(_ request: URLRequest) throws -> URLRequest {

        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            throw APIError.unknown("Could not get mutable request", "")
        }

        mutableRequest.setValue(NSDate().aws_stringValue(AWSDateISO8601DateFormat2),
                                forHTTPHeaderField: URLRequestContants.Header.xAmzDate)
        mutableRequest.setValue(URLRequestContants.ContentType.applicationJson,
                                forHTTPHeaderField: URLRequestContants.Header.contentType)
        mutableRequest.setValue(URLRequestContants.UserAgent.amplify,
                                forHTTPHeaderField: URLRequestContants.Header.userAgent)

        let endpoint: AWSEndpoint
        switch endpointType {
        case .graphQL:
            endpoint = AWSEndpoint(region: region,
                                   serviceName: URLRequestContants.appSyncServiceName,
                                   url: mutableRequest.url)
        case .rest:
            endpoint = AWSEndpoint(region: region,
                                   service: AWSServiceType.APIGateway,
                                   url: mutableRequest.url)
        }

        let signer: AWSSignatureV4Signer = AWSSignatureV4Signer(
            credentialsProvider: iamCredentialsProvider.getCredentialsProvider(),
            endpoint: endpoint)

        let task = signer.interceptRequest(mutableRequest)
        task?.waitUntilFinished()
        if let error = task?.error {
            throw APIError.operationError("Got error trying to sign", "", error)
        }

        return mutableRequest as URLRequest
    }
}
