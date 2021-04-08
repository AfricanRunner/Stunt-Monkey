//
//  LoginView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/30/21.
//

import SwiftUI
import AWSMobileClient

struct LoginView: View {
    @ObservedObject var settings = AppSettings()
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        let signInVC = SignInViewController(settings: settings)
        
        return NavigationView {
            if settings.username != "" {
                MainView(settings: settings, signInVC: signInVC)
            } else {
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 20) {
                    signInVC
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                    Button("Login In") {
                        signInVC.signInWithEmail(email: email, password: password)
                        password = ""
                    }
                    Divider()
                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 15) {
                        NavigationLink(destination: SignUpView(signInVC: signInVC)) {
                            Text("Sign Up")
                        }
                        
                        Button("Forgot Password") {
                            
                        }
                    }
                    Divider()
                    Button("Sign In with Google") {
                        signInVC.signInWithGoogle()
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
