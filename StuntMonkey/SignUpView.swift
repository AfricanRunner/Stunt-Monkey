//
//  SignUpView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/30/21.
//

import SwiftUI

//struct SignUpView: View {
//    let signInVC: SignInViewController
//    @EnvironmentObject var dataStore: AWSAppSyncDataStore
//    
//    @State var name = ""
//    @State var email = ""
//    @State var password = ""
//    @State var confirmation = false
//    
//    var body: some View {
//        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 15) {
//            TextField("Name", text: $name)
//            TextField("Email", text: $email)
//            SecureField("Password", text: $password)
//            
//            NavigationLink(destination: ConfirmationCodeView(signInVC: signInVC, email: email), isActive: $confirmation) {
//                Text("Sign Up").onTapGesture {
//                    signInVC.signUpWithEmail(name: self.name, email: self.email, password: self.password)
//                        dataStore.addUser(create: ThisUser(email: email, name: name)) { newUser in
//                            print("Created User!")
//                        }
//                        password = ""
//                    self.confirmation = true
//                }
//            }
//        }
//    }
//}
//
//struct ConfirmationCodeView: View {
//    let signInVC: SignInViewController
//    let email: String
//    
//    @State var confirmationCode = ""
//    
//    var body: some View {
//        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 15) {
//            TextField("Confirmation Code", text: $confirmationCode)
//                .keyboardType(.numberPad)
//            Button("Confirm") {
//                signInVC.confirmSignUpEmail(email: email, code: confirmationCode)
//                confirmationCode = ""
//            }
//        }
//    }
//}
