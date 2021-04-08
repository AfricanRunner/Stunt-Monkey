//
//  ContentView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/28/21.
//

import SwiftUI
import AWSMobileClient

struct ContentView: View {
    // MARK: Properties
    @ObservedObject var settings = AppSettings()
    // Sign up with Email
    @State var signUpWithEmail = false
    @State var signUpName = ""
    @State var signUpEmail = ""
    @State var signUpPassword = ""
        
    // Sign in with Email
    @State var signInWithEmail = false
    @State var signInEmail = ""
    @State var signInPassword = ""
    
    // Confirmation
    @State var confirmationCode = ""
    
    // MARK: Body
    var body: some View {
        let signInVC = SignInViewController(settings: settings)
        
        return ZStack {
            if settings.username != "" {
                VStack {
                    Text("You are signed in! Welcome!")
                    Divider()
                    Button(action: {
                        AWSMobileClient.default().signOut()
                        self.settings.username = ""
                    }) {
                        Text("Sign Out")
                    }
                }
            } else {
                signInVC
                if settings.emailNeedsConfirmation != "" {
                    VStack(spacing: 15) {
                        TextField("Confirmation Code", text: $confirmationCode)
                            .keyboardType(.numberPad)
                        HStack(spacing: 15) {
                            Button(action: {
                                self.signUpWithEmail = false
                                DispatchQueue.main.async {
                                    self.settings.emailNeedsConfirmation = ""
                                }
                            }) {
                                Text("Change Email")
                            }
                            Button(action: {
                                self.signUpWithEmail = false
                                signInVC.confirmSignUpEmail(email: self.settings.emailNeedsConfirmation, code: self.confirmationCode)
                            }) {
                                Text("Sign Up")
                            }
                        }
                    }
                } else if signUpWithEmail {
                    VStack(spacing: 15) {
                        TextField("Enter your Name", text: $signUpName)
                            .keyboardType(.alphabet)
                        TextField("Enter your Email", text: $signUpEmail)
                            .keyboardType(.emailAddress)
                        SecureField("Enter your Password", text: $signUpPassword)
                        HStack(spacing: 15) {
                            Button(action: {
                                self.signUpWithEmail = false
                            }) {
                                Text("Cancel")
                            }
                            Button(action: {
                                signInVC.signUpWithEmail(name: self.signUpName, email: self.signUpEmail, password: self.signUpPassword)
                            }) {
                                Text("Sign Up")
                            }
                        }
                    }
                    .padding(.all)
                    
                } else if signInWithEmail {
                    VStack(spacing: 15) {
                        TextField("Enter your Email", text: $signInEmail)
                            .keyboardType(.emailAddress)
                        SecureField("Enter your Password", text: $signInPassword)
                        HStack(spacing: 15) {
                            Button(action: {
                                self.signInWithEmail = false
                            }) {
                                Text("Cancel")
                            }
                            Button(action: {
                                signInVC.signInWithEmail(email: self.signInEmail, password: self.signInPassword)
                            }) {
                                Text("Sign In")
                            }
                        }
                    }
                    .padding(.all)
                    
                } else {
                    VStack(spacing: 15) {
                        Button(action: {
                            signInVC.signInWithGoogle()
                        }) {
                            Text("Sign In with Google")
                        }
                        Button(action: {
                            self.signUpWithEmail = true
                        }) {
                            Text("Sign Up with Email")
                        }
                        Button(action: {
                             self.signInWithEmail = true
                        }) {
                            Text("Sign In with Email")
                        }
                        Button(action: {
                            AWSMobileClient.default().signOut()
                            self.settings.username = ""
                        }) {
                            Text("Sign Out")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
