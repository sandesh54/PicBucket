//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSPluginsCore
import AWSS3

public class AWSS3StorageListOperation: AmplifyOperation<StorageListRequest, Void, StorageListResult, StorageError>,
    StorageListOperation {

    let storageService: AWSS3StorageServiceBehaviour
    let authService: AWSAuthServiceBehavior

    init(_ request: StorageListRequest,
         storageService: AWSS3StorageServiceBehaviour,
         authService: AWSAuthServiceBehavior,
         listener: EventListener?) {

        self.storageService = storageService
        self.authService = authService
        super.init(categoryType: .storage,
                   eventName: HubPayload.EventName.Storage.list,
                   request: request,
                   listener: listener)
    }

    override public func cancel() {
        super.cancel()
    }

    override public func main() {
        if isCancelled {
            finish()
            return
        }

        if let error = request.validate() {
            dispatch(error)
            finish()
            return
        }

        let identityIdResult = authService.getIdentityId()

        guard case let .success(identityId) = identityIdResult else {
            if case let .failure(error) = identityIdResult {
                dispatch(StorageError.authError(error.errorDescription, error.recoverySuggestion))
            }

            finish()
            return
        }

        let accessLevelPrefix = StorageRequestUtils
            .getAccessLevelPrefix(accessLevel: request.options.accessLevel,
                                  identityId: identityId,
                                  targetIdentityId: request.options.targetIdentityId)

        if isCancelled {
            finish()
            return
        }

        storageService.list(prefix: accessLevelPrefix, path: request.options.path) { [weak self] event in
            self?.onServiceEvent(event: event)
        }
    }

    private func onServiceEvent(event: StorageEvent<Void, Void, StorageListResult, StorageError>) {
        switch event {
        case .completed(let result):
            dispatch(result)
            finish()
        case .failed(let error):
            dispatch(error)
            finish()
        default:
            break
        }
    }

    private func dispatch(_ result: StorageListResult) {
        let asyncEvent = AsyncEvent<Void, StorageListResult, StorageError>.completed(result)
        dispatch(event: asyncEvent)
    }

    private func dispatch(_ error: StorageError) {
        let asyncEvent = AsyncEvent<Void, StorageListResult, StorageError>.failed(error)
        dispatch(event: asyncEvent)
    }
}
