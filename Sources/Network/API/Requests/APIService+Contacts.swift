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

import Alamofire

extension APIService {
    
    internal func fetchContacts(type: ContactType? = nil, completion: @escaping RequestCompletion<APIPaginatedResponse<APIContactResponse>>) {
        requestQueue.async {
            let url = URL(string: ContactsEndpoint.contacts(type: type).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                print(String(data: response.data!, encoding: .utf8))
                self.network.handlePaginatedArrayResponse(type: APIContactResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
}
