//
//  SignUpView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/30/21.
//

import SwiftUI

struct SignUpView: View {
    let signInVC: SignInViewController
    
    @State var name = ""
    @State var email = ""
    @State var password = ""
    
    var body: some View {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 15) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                NavigationLink(destination: ConfirmationCodeView(signInVC: signInVC, email: email)) {
                    Text("Sign Up")
                }.onTapGesture {
                    print("Signin Up!")
                    signInVC.signUpWithEmail(name: self.name, email: self.email, password: self.password)
                    password = ""
                }
            }
    }
}

struct ConfirmationCodeView: View {
    let signInVC: SignInViewController
    let email: String
    
    @State var confirmationCode = ""
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 15) {
            TextField("Confirmation Code", text: $confirmationCode)
                .keyboardType(.numberPad)
            Button("Confirm") {
                signInVC.confirmSignUpEmail(email: email, code: confirmationCode)
                confirmationCode = ""
            }
        }
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}
