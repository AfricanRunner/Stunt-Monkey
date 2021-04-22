//
//  LoginView.swift
//  StuntMonkey
//
//  Created by Daniël du Preez on 3/30/21.
//

import SwiftUI
import AWSMobileClient

struct MotherView: View {
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    @EnvironmentObject var router: ViewRouter
    @EnvironmentObject var settings: AppSettings
    
    @State var signInVC: SignInViewController
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        if settings.username != "" {
            MainView(settings: settings, signInVC: signInVC)
        } else {
            switch router.currentPage {
            case .login:
                LoginView(signInVC: signInVC)
            case .signUp:
                SignUpView(signInVC: signInVC)
            case .confirm:
                ConfirmationView(signInVC: signInVC)
            case .application:
                Text("Confirming...")
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    @EnvironmentObject var router: ViewRouter
    
    let signInVC: SignInViewController
    
    let width: CGFloat = 300
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
//            Text("Stunt Monkey").font(.title)
            Image("MonkeyFace").resizable()
                .aspectRatio(contentMode: .fit).frame(width: width)
            TextField("Email", text: $email).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: width).keyboardType(.emailAddress)
            SecureField("Password", text: $password).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: width)
            HStack {
                Button(action: {
                    signInVC.signInWithEmail(email: email, password: password)
                    password = ""
                }) {
                    SMButton(text: "Sign In")
                }.frame(width: width / 2)
                Button(action: {
                    router.currentPage = .signUp
                }) {
                    SMButton(text: "Sign Up")
                }.frame(width: width / 2)
            }.frame(width: width)
        }.padding()
        .frame(width: 150)
    }
}

struct SignUpView: View {
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    @EnvironmentObject var router: ViewRouter
    
    let signInVC: SignInViewController
    
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Text("Create Account").font(.title)
            TextField("Name", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Email", text: $email).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.emailAddress)
            SecureField("Password", text: $password).textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                signInVC.signUpWithEmail(name: self.name, email: self.email, password: self.password)
                dataStore.addUser(create: ThisUser(email: email, name: name)) { newUser in
                    print("Created User!")
                }
                print("INDEX 1")
                print(name, email, password)
                password = ""
                router.currentPage = .confirm
            }) {
                SMButton(text: "Confirm")
            }
        }.frame(width: 300)
    }
}

struct ConfirmationView: View {
    @EnvironmentObject var dataStore: AWSAppSyncDataStore
    @EnvironmentObject var router: ViewRouter
    @EnvironmentObject var settings: AppSettings
    
    let signInVC: SignInViewController
    
    @State var code: String = ""
    
    var body: some View {
        VStack {
            Text("Confirm Email").font(.title)
            TextField("Confirmation Code", text: $code).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.numberPad)
            Button(action: {
                signInVC.confirmSignUpEmail(email: settings.emailNeedsConfirmation, code: code)
                code = ""
                router.currentPage = .login
                print("Index 2")
                print(settings.username)
            }) {
                SMButton(text: "Confirm")
            }
        }.frame(width: 300)
    }
}

struct SMButton: View {
    var text: String
    
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .frame(width: 120, height: 50)
            .background(Color.blue)
            .cornerRadius(15)
//            .padding(.top, 50)


    }
}

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .login
}

enum Page {
    case login
    case signUp
    case confirm
    case application
}
