//
// Copyright © 2019 Frollo. All rights reserved.
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

/// A value that represents either a success or a failure, including an associated error on failure.
public enum EmptyResult<Failure> {
    
    /// A success
    case success
    
    /// A failure, storing a `Failure` value.
    case failure(Failure)
    
}

/// A value that represents either a success (with before and after cursors for pagination)or a failure, including an associated error on failure.
public enum PaginatedResult<Failure, before, after> {
    
    /// A success
    case success(before, after)
    
    /// A failure, storing a `Failure` value.
    case failure(Failure)
    
}

/// A value that represents either a success (with before and after cursors for pagination)or a failure, including an associated error on failure.
public enum TransactionPaginatedResult<Failure, before, after> {
    
    /// A success
    case success(before, after)
    
    /// A failure, storing a `Failure` value.
    case failure(Failure)
    
}
