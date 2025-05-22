//
//  SwiftUIView.swift
//  CrossCart
//
//  Created by shruti's macbook on 19/05/25.
//

import SwiftUI
import Combine

struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var navigateToForgotPassword = false
    @StateObject var loginCall = LoginService()
   
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                    .accessibilityIdentifier("loginText")
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .accessibilityIdentifier("usernameField")
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .accessibilityIdentifier("passwordField")
                Button(action : {
                    loginCall.login(username: username, password: password)
                }) {
                    Text("Login")
                }
                .disabled(username.isEmpty || password.isEmpty)
                .padding()
                .background((username.isEmpty || password.isEmpty) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .accessibilityIdentifier("loginButton")
                Button("Forgot Password?") {
                    navigateToForgotPassword = true
                }
                .foregroundColor(.blue)
                .accessibilityIdentifier("forgotPasswordButton")
                NavigationLink("", destination: ForgotPasswordView(), isActive: $navigateToForgotPassword)
            }
            .padding()
        }
    }
    
   
}

import SwiftUI
struct ForgotPasswordView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot Password")
                .font(.title)
                .bold()
            Text("Please contact support to reset your password.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .accessibilityIdentifier("forgotPasswordScreen")
    }
}

class LoginService : ObservableObject {
    
    func login(username : String , password: String) -> AnyPublisher<Bool,Never> {
        return Just(username == username && password == password)
            .delay(for: 2, scheduler: RunLoop.main)
            .eraseToAnyPublisher()

    }
}


