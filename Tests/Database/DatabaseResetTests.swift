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

import CoreData
import XCTest
@testable import FrolloSDK

class DatabaseResetTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func insertTestData(database: Database) {
        let context = database.newBackgroundContext()
        
        context.performAndWait {
            for entity in database.persistentContainer.managedObjectModel.entities {
                guard let entityName = entity.name
                    else {
                        continue
                }
                
                for _ in 0..<100 {
                    let model = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
                    if let testableModel = model as? TestableCoreData {
                        testableModel.populateTestData()
                    }
                }
            }
            
            do {
                try context.save()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func checkDatabaseEmpty(database: Database) {
        let context = database.viewContext
        
        for entity in database.persistentContainer.managedObjectModel.entities {
            guard let entityName = entity.name
                else {
                    continue
            }
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            fetchRequest.resultType = .dictionaryResultType
            
            let results = try! context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 0)
        }
    }

    // MARK: - Reset test
    
    func testDatabaseReset() {
        let expectation1 = expectation(description: "Reset Callback")
        
        let path = tempFolderPath()
        
        let database = Database(path: path)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.insertTestData(database: database)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                database.reset() { (error) in
                    XCTAssertNil(error)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.checkDatabaseEmpty(database: database)
                        
                        expectation1.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation1], timeout: 30.0)
        
        try? FileManager.default.removeItem(at: path)
    }

}
