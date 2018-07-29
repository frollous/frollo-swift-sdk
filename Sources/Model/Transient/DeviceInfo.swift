//
//  DeviceInfo.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 27/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

#if os(macOS)
import IOKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

struct DeviceInfo {
    
    let deviceID: String
    let deviceName: String
    let deviceType: String
    
    static func current() -> DeviceInfo {
        #if os(macOS)
        let deviceID = serialNumber()
        let deviceName = Host.current().name ?? "Unknown"
        let deviceType = modelIdentifier()
        #else
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let deviceName = UIDevice.current.name
        let deviceType = platform()
        #endif
        
        return DeviceInfo(deviceID: deviceID, deviceName: deviceName, deviceType: deviceType)
    }
    
    /**
     Cross platform name
     
     - returns: String with hardware ID of the device, e.g. iPhone1,2
    */
    static func platform() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /**
     Model identifier of the Mac
     
     - Note: Use DeviceInfo platform() on other platforms
     
     - returns: Model identifier or "Unknown" if the model can't be retrieved
    */
    #if os(macOS)
    @available (macOS 10.3, *)
    static func modelIdentifier() -> String {
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        
        defer { IOObjectRelease(platformExpert) }
        
        let property = IORegistryEntryCreateCFProperty(platformExpert, "model" as CFString, kCFAllocatorDefault, 0)
        
        if let modelData = property?.takeUnretainedValue() as? Data, let model = String(data: modelData, encoding: .utf8) {
            return model
        }
        
        return "Unknown"
    }
    
    /**
     Serial number of the Mac
     
     - Note: Use UIDevice identifierForVendor on other platforms
     
     - returns: Serial number or "Unknown" if the serial can't be retrieved
    */
    @available (macOS 10.3, *)
    static func serialNumber() -> String {
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        
        defer { IOObjectRelease(platformExpert) }
        
        let property = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0)
        
        return property?.takeUnretainedValue() as? String ?? "Unknown"
    }
    #endif
    
}
