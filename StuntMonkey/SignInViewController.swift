//
//  SignInViewController.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/29/21.
//

import SwiftUI
import AWSMobileClient

struct SignInViewController: UIViewControllerRepresentable {
    @ObservedObject var settings = AppSettings()
    let navController =  UINavigationController()
    
    func makeUIViewController(context: Context) -> UINavigationController {
        navController.setNavigationBarHidden(true, animated: false)
        let viewController = UIViewController()
        navController.addChild(viewController)
        return navController
    }
    
    func updateUIViewController(_ pageViewController: UINavigationController, context: Context)   {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: SignInViewController
        
        init(_ signInViewController: SignInViewController) {
            self.parent = signInViewController
        }
    }
    
    
}

// MARK: Sign In With Google Extension
extension SignInViewController {
    
    func forgotPassword(email: String) {
        AWSMobileClient.default().forgotPassword(username: email) { (forgotPasswordResult, error) in
            if let error = error as? AWSMobileClientError {
                print("error : \(error)")
                print("error localizedDescription: \(error.localizedDescription)")
            } else if let forgotPasswordResult = forgotPasswordResult {
                print(forgotPasswordResult.codeDeliveryDetails)
                print("Successfully requested new password?")
            }
        }
    }
    
    func signInWithEmail(email: String, password: String){
            let username = email
            
            AWSMobileClient.default().signIn(username: username, password: password) { (signInResult, error) in
                if let error = error as? AWSMobileClientError {
                    print("error : \(error)")
                    print("error localizedDescription: \(error.localizedDescription)")
                } else if let signInResult = signInResult {
                    switch (signInResult.signInState) {
                        case .signedIn:
                            print("User is signed in.")
                            
                            self.getTokens { claims in
                                if let username = claims?["email"] as? String {
                                    DispatchQueue.main.async {
                                        self.settings.username = username
                                    }
                                }
                            }
                        case .smsMFA:
                            print("SMS message sent to \(signInResult.codeDetails!.destination!)")
                        default:
                            print("Sign In needs info which is not yet supported.")
                    }
                }
            }
        }
    
    func confirmSignUpEmail(email: String, code: String) {
           let username = email
           AWSMobileClient.default().confirmSignUp(username: username, confirmationCode: code) { (confirmationResult, error) in
               if let error = error  as? AWSMobileClientError {
                   print("error : \(error)")
                   print("error localizedDescription: \(error.localizedDescription)")
               } else if let confirmationResult = confirmationResult {
                   switch(confirmationResult.signUpConfirmationState) {
                       case .confirmed:
                           print("User is signed up and confirmed.")
                           DispatchQueue.main.async {
                               self.settings.emailNeedsConfirmation = ""
                           }
                       case .unconfirmed:
                           print("User is not confirmed and needs verification via \(confirmationResult.codeDeliveryDetails!.deliveryMedium) sent at \(confirmationResult.codeDeliveryDetails!.destination!)")
                       case .unknown:
                           print("Unexpected case")
                   }
               }
           }
       }
    
    func getTokens(closure: @escaping ([String : AnyObject]?) -> ()) {
        AWSMobileClient.default().getTokens { (tokens, error) in
            if let error = error {
                print("error \(error)")
            } else if let tokens = tokens {
                let claims = tokens.idToken?.claims
                print("username? \(claims?["username"] as? String ?? "No username")")
                print("cognito:username? \(claims?["cognito:username"] as? String ?? "No cognito:username")")
                print("email? \(claims?["email"] as? String ?? "No email")")
                print("name? \(claims?["name"] as? String ?? "No name")")
                print("picture? \(claims?["picture"] as? String ?? "No picture")")

                closure(claims)

            }
        }
    }
        
    func signUpWithEmail(name: String, email: String, password: String) {
        // Since we don't have a username when signing up with Email, use the email as a username
        let username = email
        AWSMobileClient.default().signUp(username: username, password: password, userAttributes: ["email":email, "name": name, "picture": ""]) { (signUpResult, error) in
            if let error = error as? AWSMobileClientError {
                print("error : \(error)")
                print("error localizedDescription : \(error.localizedDescription)")
            } else if let signUpResult = signUpResult {
                switch(signUpResult.signUpConfirmationState) {
                    case .confirmed:
                        print("User is signed up and confirmed.")
                    case .unconfirmed:
                        print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
                        DispatchQueue.main.async {
                            self.settings.emailNeedsConfirmation = username
                        }
                    case .unknown:
                        print("Unexpected case")
                }
            }
        }
    }
    
    func signInWithGoogle() {
        let hostedUIOptions = HostedUIOptions(scopes: ["openid", "email", "profile"], identityProvider: "Google")

        AWSMobileClient.default().showSignIn(navigationController: navController, hostedUIOptions: hostedUIOptions) { (userState, error) in
            if let error = error as? AWSMobileClientError {
                print(error.localizedDescription)
            }
            if let userState = userState {
                print("Status: \(userState.rawValue)")
                
                AWSMobileClient.default().getTokens { (tokens, error) in
                    if let error = error {
                        print("error \(error)")
                    } else if let tokens = tokens {
                        let claims = tokens.idToken?.claims
                        print("username? \(claims?["username"] as? String ?? "No username")")
                        print("cognito:username? \(claims?["cognito:username"] as? String ?? "No cognito:username")")
                        print("email? \(claims?["email"] as? String ?? "No email")")
                        print("name? \(claims?["name"] as? String ?? "No name")")
                        if let username = claims?["email"] as? String {
                            DispatchQueue.main.async {
                                self.settings.username = username
                            }
                        }
                    }
                }
            }
            
        }
    }
}
