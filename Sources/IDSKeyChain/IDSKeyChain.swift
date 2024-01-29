//
//  KeyChain.swift
//  TodayWidgetRDExtension
//
//  Created by su on 01.10.2020.
//  Copyright © 2020 Moleculus. All rights reserved.
//

import Foundation
import Security

public class IDSKeyChain {
    public static var loggingEnabled = false
    
    public class subscript(key: String) -> Any? {
        get {
            return load(withKey: key)
        } set {
            DispatchQueue.global().sync(flags: .barrier) {
                self.save(Data(from: newValue), forKey: key)
            }
        }
    }
    
    @discardableResult public class func save(_ data: Data?, forKey key: String) -> OSStatus {
        let query = keychainQuery(withKey: key)
        
        if SecItemCopyMatching(query, nil) == noErr {
            if let data = data {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: data]))
                logPrint("Update status: ", status)
                return status
            } else {
                let status = SecItemDelete(query)
                logPrint("Delete status: ", status)
                return status
            }
        } else {
            if let data = data {
                query.setValue(data, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                logPrint("Update status: ", status)
                return status
            } else {
                return noErr
            }
        }
    }
    
    public class func load(withKey key: String) -> Data? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            logPrint("Load status: ", status)
            return nil
        }
        return resultsData
    }
    
    @discardableResult public class func remove(withKey key: String) -> OSStatus {
        let query = keychainQuery(withKey: key)
        let status = SecItemDelete(query)
        logPrint("Delete status: ", status)
        return status
    }
    
    class private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAlwaysThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
    
    class private func logPrint(_ items: Any...) {
        if loggingEnabled {
            print(items)
        }
    }
}

public extension Data {
    init<T>(from value: T) {
        self = withUnsafePointer(to: value) { (ptr: UnsafePointer<T>) -> Data in
            return Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
