//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/**
 Events
 
 Manages triggering and handling of events from the host
 */
public class Events {
    
    internal struct EventNames {
        static let test = "TEST_EVENT"
        static let transactionsUpdated = "T_UPDATED"
        static let currentBudgetPeriodReady = "B_CURRENT_PERIOD_READY"
        static let onboardingStepCompleted = "ONBOARDING_STEP_COMPLETED"
        static let linkProviderAccountFailed = "PA_FAILED"
        static let providerAccountLinked = "PA_LINKED"
        static let mfaRequest = "PA_MFA"
    }
    
    internal weak var delegate: FrolloSDKDelegate?
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
    }
    
    /**
     Trigger an event to occur on the host
     
     - parameters:
        - eventName: Name of the event to trigger. Unrecognised ones will be ignored by the host
        - delay: Delay in minutes for the host to delay the event (optional)
        - completion: Completion handler with option error if something occurs (optional)
     */
    public func triggerEvent(_ eventName: String, after delay: Int64? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        let request = APIEventCreateRequest(delayMinutes: delay ?? 0,
                                            event: eventName)
        
        service.createEvent(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Handle an event internally in case it triggers an actions
     
     - parameters:
        - eventName: Name of the event to be handled. Unrecognised ones will be ignored
        - notification: Payload of the associated notification (optional)
        - completion: Completion handler indicating if the event was handled and any error that may have occurred (optional)
     */
    internal func handleEvent(_ eventName: String, notification: NotificationPayload? = nil, completion: ((_ handled: Bool, _ error: Error?) -> Void)? = nil) {
        defer {
            DispatchQueue.main.async {
                self.delegate?.eventTriggered(eventName: eventName)
            }
        }
        
        switch eventName {
            case EventNames.test:
                Log.info("Test event received")
                
                completion?(true, nil)
                
            case EventNames.transactionsUpdated:
                Log.debug("Transactions updated event received")
                
                if let transactionIDs = notification?.transactionIDs, !transactionIDs.isEmpty {
                    NotificationCenter.default.post(name: Aggregation.refreshTransactionsNotification, object: self, userInfo: [Aggregation.refreshTransactionIDsKey: transactionIDs])
                }
                
                completion?(true, nil)
                
            case EventNames.currentBudgetPeriodReady:
                Log.debug("Current budget period ready event received")
                
                NotificationCenter.default.post(name: Budgets.currentBudgetPeriodReadyNotification, object: self, userInfo: nil)
                
                completion?(true, nil)
                
            case EventNames.onboardingStepCompleted:
                Log.debug("Onboarding step complete event received")
                
                if let onboardingStep = notification?.onboardingStep {
                    NotificationCenter.default.post(name: UserManagement.onboardingStepCompletedNotification, object: self, userInfo: [UserManagement.onboardingEventKey: onboardingStep])
                }
                
                completion?(true, nil)
                
            case EventNames.providerAccountLinked:
                Log.debug("Provider Account Linking failed")
                
                NotificationCenter.default.post(name: Aggregation.providerAccountLinkedNotification, object: self, userInfo: nil)
                completion?(true, nil)
                
            case EventNames.linkProviderAccountFailed:
                Log.debug("Provider Account Linked successfully")
                
                NotificationCenter.default.post(name: Aggregation.providerAccountLinkingFailedNotification, object: self, userInfo: nil)
                completion?(true, nil)
                
            case EventNames.mfaRequest:
                Log.debug("MFA is required for the providerAccount being linked")
                
                NotificationCenter.default.post(name: Aggregation.providerAccountMFARequiredNotification, object: self, userInfo: nil)
                completion?(true, nil)
                
            default:
                // Event not recognised
                completion?(false, nil)
        }
    }
    
}
