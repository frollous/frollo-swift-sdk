//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
import CoreData
@testable import FrolloSDK

class CustomMessageMigrationTest: XCTestCase {

    func testMessageMigration() {
        
        let oldModelUrl = Bundle(for: Database.self).url(forResource: "FrolloSDKDataModel.momd/FrolloSDKDataModel-1.5.1", withExtension: "mom")!
        let oldManagedObjectModel = NSManagedObjectModel(contentsOf: oldModelUrl)
        
        let newModelUrl = Bundle(for: Database.self).url(forResource: "FrolloSDKDataModel.momd/FrolloSDKDataModel-1.5.2", withExtension: "mom")!
        let newManagedObjectModel = NSManagedObjectModel(contentsOf: newModelUrl)
        
        XCTAssertNotNil(oldManagedObjectModel)
        XCTAssertNotNil(newManagedObjectModel)

        let coordinator = NSPersistentStoreCoordinator.init(managedObjectModel: oldManagedObjectModel!)
        let url = tempFolderPath().appendingPathComponent(Database.DatabaseConstants.storeName + "notmigrated").appendingPathExtension(Database.DatabaseConstants.storeExtension)
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options:[NSMigratePersistentStoresAutomaticallyOption: false, NSInferMappingModelAutomaticallyOption: false])
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator

        let oldMessage = NSEntityDescription.insertNewObject(forEntityName: "Message", into: managedObjectContext)
        setMessageProperties(object: oldMessage)
        oldMessage.setValue(true, forKey: "actionOpenExternal")
        oldMessage.setValue(1, forKey: "messageID")
        oldMessage.setValue("Test Parent Message", forKey: "title")
        
        let oldHTMLMessage = NSEntityDescription.insertNewObject(forEntityName: "MessageHTML", into: managedObjectContext)
        setMessageProperties(object: oldHTMLMessage)
        oldHTMLMessage.setValue(true, forKey: "actionOpenExternal")
        oldHTMLMessage.setValue(2, forKey: "messageID")
        oldHTMLMessage.setValue("Test HTML Message", forKey: "title")
        oldHTMLMessage.setValue("main", forKey: "main")
        
        let oldTextMessage = NSEntityDescription.insertNewObject(forEntityName: "MessageText", into: managedObjectContext)
        setMessageProperties(object: oldTextMessage)
        oldTextMessage.setValue(true, forKey: "actionOpenExternal")
        oldTextMessage.setValue(3, forKey: "messageID")
        oldTextMessage.setValue("Test Text Message", forKey: "title")
        
        let oldImageMessage = NSEntityDescription.insertNewObject(forEntityName: "MessageImage", into: managedObjectContext)
        setMessageProperties(object: oldImageMessage)
        oldImageMessage.setValue(false, forKey: "actionOpenExternal")
        oldImageMessage.setValue(4, forKey: "messageID")
        oldImageMessage.setValue("Test Image Message", forKey: "title")
        oldImageMessage.setValue("test Url", forKey: "urlString")
        
        let oldVideoMessage = NSEntityDescription.insertNewObject(forEntityName: "MessageVideo", into: managedObjectContext)
        setMessageProperties(object: oldVideoMessage)
        oldVideoMessage.setValue(false, forKey: "actionOpenExternal")
        oldVideoMessage.setValue(5, forKey: "messageID")
        oldVideoMessage.setValue("Test Video Message", forKey: "title")
        oldVideoMessage.setValue("test Url", forKey: "urlString")
        
        try! managedObjectContext.save()
        
        let mappingModel = NSMappingModel(from: nil, forSourceModel: oldManagedObjectModel!, destinationModel: newManagedObjectModel!)

        XCTAssertNotNil(mappingModel)

        let migrationManager = NSMigrationManager(sourceModel: oldManagedObjectModel!,
                   destinationModel: newManagedObjectModel!)
        let newUrl = tempFolderPath().appendingPathComponent(Database.DatabaseConstants.storeName + "migrated").appendingPathExtension(Database.DatabaseConstants.storeExtension)

        do {
            try migrationManager.migrateStore(from: url,
                                    sourceType: NSSQLiteStoreType,
                                    options: nil,
                                    with: mappingModel,
            toDestinationURL: newUrl,
            destinationType: NSSQLiteStoreType,
            destinationOptions: nil)
            
        }catch {
            XCTAssertNil(error)
        }
        
        let newCoordinator = NSPersistentStoreCoordinator(managedObjectModel: newManagedObjectModel!)
        try! newCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil, at: newUrl, options: nil)

        let newManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        newManagedObjectContext.persistentStoreCoordinator = newCoordinator

        let messageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        messageRequest.predicate = NSPredicate(format: "messageID == 1", [])
        let message = try! newManagedObjectContext.fetch(messageRequest).first as? Message
        XCTAssertEqual(message?.openModeRawValue, Message.OpenMode.external.rawValue)
        XCTAssertEqual(message?.title, "Test Parent Message")
        XCTAssertEqual(message?.messageID, 1)
        
        let htmlMessageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageHTML")
        let htmlMessage = try! newManagedObjectContext.fetch(htmlMessageRequest).first as? MessageHTML
        XCTAssertEqual(htmlMessage?.openModeRawValue, Message.OpenMode.external.rawValue)
        XCTAssertEqual(htmlMessage?.title, "Test HTML Message")
        XCTAssertEqual(htmlMessage?.messageID, 2)
        
        let textMessageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageText")
        let textMessage = try! newManagedObjectContext.fetch(textMessageRequest).first as? MessageText
        XCTAssertEqual(textMessage?.openModeRawValue, Message.OpenMode.external.rawValue)
        XCTAssertEqual(textMessage?.title, "Test Text Message")
        XCTAssertEqual(textMessage?.messageID, 3)
        
        let imageMessageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageImage")
        let imageMessage = try! newManagedObjectContext.fetch(imageMessageRequest).first as? MessageImage
        XCTAssertEqual(imageMessage?.openModeRawValue, Message.OpenMode.internalOpen.rawValue)
        XCTAssertEqual(imageMessage?.title, "Test Image Message")
        XCTAssertEqual(imageMessage?.messageID, 4)
        
        let videoMessageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageVideo")
        let videoMessage = try! newManagedObjectContext.fetch(videoMessageRequest).first as? MessageVideo
        XCTAssertEqual(videoMessage?.openModeRawValue, Message.OpenMode.internalOpen.rawValue)
        XCTAssertEqual(videoMessage?.title, "Test Video Message")
        XCTAssertEqual(videoMessage?.messageID, 5)
        
        try! FileManager.default.removeItem(at: url)
        try! FileManager.default.removeItem(at: newUrl)
        
    }
    
    func setMessageProperties(object: NSManagedObject) {
        object.setValue("Action Title", forKey: "actionTitle")
        object.setValue("testurlString", forKey: "actionURLString")
        object.setValue(true, forKey: "autoDismiss")
        object.setValue("testevent", forKey: "event")
        object.setValue(true, forKey: "interacted")
        object.setValue(true, forKey: "persists")
        object.setValue(2, forKey: "placement")
        object.setValue(true, forKey: "read")
        object.setValue("video", forKey: "typesRawValue")
        object.setValue(3, forKey: "userEventID")
    }

}
