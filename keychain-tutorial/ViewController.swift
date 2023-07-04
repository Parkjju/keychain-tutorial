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
    let keychainManager = KeychainManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performExistingAccountSetupFlows()
        
        setupProviderLoginView()
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
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = "rudwns3927@gmail.com"
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            do{
                try keychainManager.saveItem(userIdentifier, itemClass: .password, key: fullName)
            }catch{
                print(error)
            }
            
            
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            print("PASSWORD..")
            // For the purpose of this demo app, show the password credential as an alert.
//            DispatchQueue.main.async {
//                self.showPasswordCredentialAlert(username: username, password: password)
//            }
            
            
        default:
            break
        }
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
