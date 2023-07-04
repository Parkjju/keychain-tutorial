//
//  KeyChainError.swift
//  keychain-tutorial
//
//  Created by 박경준 on 2023/07/04.
//

import Foundation

class KeychainManager{
    typealias ItemAttributes = [CFString: Any]
    typealias KeychainDictionary = [String: Any]
    
    static let shared = KeychainManager()
    
    private init(){}
    
    // MARK: Create
    func saveItem<T: Encodable>(
        _ item: T,
        itemClass: ItemClass,
        key: String,
        attributes: ItemAttributes? = nil) throws {

            // 1
            let itemData = try JSONEncoder().encode(item)

            // 2
            var query: [String: AnyObject] = [
                kSecClass as String: itemClass.rawValue,
                kSecAttrAccount as String: key as AnyObject,
                kSecValueData as String: itemData as AnyObject
            ]

            // 3
            if let itemAttributes = attributes {
                for(key, value) in itemAttributes {
                    query[key as String] = value as AnyObject
                }
            }

            // 4
            let result = SecItemAdd(query as CFDictionary, nil)

            // 5
            if result != errSecSuccess {
                throw convertError(result)
            }
        }
    
    // MARK: Read
    func retrieveItem<T: Decodable>(
       ofClass itemClass: ItemClass,
       key: String, attributes:
       ItemAttributes? = nil) throws -> T {

       // 1
       var query: KeychainDictionary = [
          kSecClass as String: itemClass.rawValue,
          kSecAttrAccount as String: key as AnyObject,
          kSecReturnAttributes as String: true,
          kSecReturnData as String: true
       ]

       // 2
       if let itemAttributes = attributes {
          for(key, value) in itemAttributes {
             query[key as String] = value as AnyObject
          }
       }

       // 3
       var item: CFTypeRef?

       // 4
       let result = SecItemCopyMatching(query as CFDictionary, &item)

       // 5
       if result != errSecSuccess {
          throw convertError(result)
       }

       // 6
       guard
          let keychainItem = item as? [String : Any],
          let data = keychainItem[kSecValueData as String] as? Data
       else {
          throw KeychainError.invalidData
       }

       // 7
       return try JSONDecoder().decode(T.self, from: data)
    }
    // MARK: Update
    func updateItem<T: Encodable>(
       with item: T,
       ofClass itemClass: ItemClass,
       key: String,
       attributes: ItemAttributes? = nil) throws {

       let itemData = try JSONEncoder().encode(item)

       var query: KeychainDictionary = [
          kSecClass as String: itemClass.rawValue,
          kSecAttrAccount as String: key as AnyObject
       ]

       if let itemAttributes = attributes {
          for(key, value) in itemAttributes {
             query[key as String] = value as AnyObject
          }
       }

       let attributesToUpdate: KeychainDictionary = [
          kSecValueData as String: itemData as AnyObject
       ]

       let result = SecItemUpdate(
          query as CFDictionary,
          attributesToUpdate as CFDictionary
       )

       if result != errSecSuccess {
          throw convertError(result)
       }
    }
    
    func deleteItem(
       ofClass itemClass: ItemClass,
       key: String, attributes:
       ItemAttributes? = nil) throws {

       var query: KeychainDictionary = [
          kSecClass as String: itemClass.rawValue,
          kSecAttrAccount as String: key as AnyObject
       ]

       if let itemAttributes = attributes {
          for(key, value) in itemAttributes {
             query[key as String] = value as AnyObject
          }
       }

       let result = SecItemDelete(query as CFDictionary)
       if result != errSecSuccess {
          throw convertError(result)
       }
    }
}

// MARK: 1. 키체인 아이템 클래스 커스텀 열거형 정의
extension KeychainManager{
    enum ItemClass: RawRepresentable {
         typealias RawValue = CFString

         case generic
         case password
         case certificate
         case cryptography
         case identity

         init?(rawValue: CFString) {
            switch rawValue {
            case kSecClassGenericPassword:
               self = .generic
            case kSecClassInternetPassword:
               self = .password
            case kSecClassCertificate:
               self = .certificate
            case kSecClassKey:
               self = .cryptography
            case kSecClassIdentity:
               self = .identity
            default:
               return nil
            }
         }

         var rawValue: CFString {
            switch self {
            case .generic:
               return kSecClassGenericPassword
            case .password:
               return kSecClassInternetPassword
            case .certificate:
               return kSecClassCertificate
            case .cryptography:
               return kSecClassKey
            case .identity:
               return kSecClassIdentity
            }
         }
      }
}

// MARK: 2. 키체인 에러 정의
extension KeychainManager{
    enum KeychainError: Error {
       case invalidData
       case itemNotFound
       case duplicateItem
       case incorrectAttributeForClass
       case unexpected(OSStatus)

       var localizedDescription: String {
          switch self {
          case .invalidData:
             return "Invalid data"
          case .itemNotFound:
             return "Item not found"
          case .duplicateItem:
             return "Duplicate Item"
          case .incorrectAttributeForClass:
             return "Incorrect Attribute for Class"
          case .unexpected(let oSStatus):
             return "Unexpected error - \(oSStatus)"
          }
       }
    }
    
    private func convertError(_ error: OSStatus) -> KeychainError {
       switch error {
       case errSecItemNotFound:
          return .itemNotFound
       case errSecDataTooLarge:
          return .invalidData
       case errSecDuplicateItem:
          return .duplicateItem
       default:
          return .unexpected(error)
       }
    }
}
