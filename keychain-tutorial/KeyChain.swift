//
//  KeyChain.swift
//  keychain-tutorial
//
//  Created by 박경준 on 2023/07/04.
//

import Foundation

public protocol KeyChainProtocol {
    func add(_ query: [String: Any]) -> OSStatus
    func search(_ query: [String: Any]) -> Data?
    func update(_ query: [String: Any], with attributes: [String: Any]) -> OSStatus
    func delete(_ query: [String: Any]) -> OSStatus
}

class KeyChain: KeyChainProtocol{
    func update(_ query: [String: Any], with attributes: [String: Any]) -> OSStatus {
        print (SecItemUpdate(query as CFDictionary, attributes as CFDictionary))
        return 0 // SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }
    
    func search(_ query: [String : Any]) -> Data? {
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    func add(_ query: [String : Any]) -> OSStatus {
        _ = delete(query)
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    func delete(_ query: [String: Any]) -> OSStatus {
        return SecItemDelete(query as CFDictionary)
    }
}
