//
//  LoginView.swift
//  CrossCart
//
//  Created by shruti's macbook on 24/04/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigate = false
    
    var body: some View {
        ZStack(alignment: .top){
            Color.appTheme
            VStack {
                Text("Login")
                    .font(.headline)
                    .foregroundStyle(Color.black)
                    .padding(.top,60)
                VStack(alignment: .leading){
                    Text("Email").foregroundStyle(Color.black)
                    TextField("", text: $email)
                        .customTextFieldStyle()
                    Text("Password").foregroundStyle(Color.black)
                    TextField("", text: $password)
                        .customTextFieldStyle()
                    Button(action: {
                        
                    }){
                        Text("Forgot Password?").foregroundStyle(Color.black)
                    }
                }
                Button("Login"){
                    navigate = true
                } .customButtonStyle()
                Spacer()
                
                Text("Don't have an account? Sign Up").foregroundStyle(Color.black)
            }
            .padding()
            .foregroundStyle(Color.white)
            //  NavigationLink("", destination: PhoneVerificationView(),isActive: $navigate)
            .onAppear {
                
            }.navigationTitle("Login").bold()
           .foregroundStyle(Color.white)
        }.ignoresSafeArea()
           
    }
}
