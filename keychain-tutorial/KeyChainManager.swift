//
//  KeyChainError.swift
//  keychain-tutorial
//
//  Created by 박경준 on 2023/07/04.
//

import Foundation

class KeychainManager{
    typealias ItemAttributes = [CFString: Any]
    
    static let shared = KeychainManager()
    
    private init(){}
}

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
