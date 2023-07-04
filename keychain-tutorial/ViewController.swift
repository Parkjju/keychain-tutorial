//
//  ViewController.swift
//  keychain-tutorial
//
//  Created by 박경준 on 2023/07/04.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
    var ref: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProviderLoginView()
        let query = [
          kSecAttrServer: "pullipstyle1.com",
          kSecAttrAccount: "andyibanez1",
          kSecClass: kSecClassInternetPassword,
          kSecReturnData: true,
          kSecReturnAttributes: true,
        ] as CFDictionary
        
        let deleteQuery = [
            kSecAttrServer: "pullipstyle1.com",
            kSecAttrAccount: "andyibanez1",
            kSecClass: kSecClassInternetPassword
        ] as CFDictionary
        
        let status = SecItemDelete(deleteQuery)
        print("delete completed with status: \(status)")
        
        
        
        
        
        
        
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.view.addSubview(authorizationButton)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        authorizationButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        authorizationButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    @objc func handleAuthorizationAppleIDButtonPress(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension ViewController: ASAuthorizationControllerDelegate{
    
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
