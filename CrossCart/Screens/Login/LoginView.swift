//
//  LoginView.swift
//  CrossCart
//
//  Created by shruti's macbook on 24/04/25.
//

import SwiftUI

struct LoginView: View  {
   
    @StateObject var viewModel = LoginViewModel()
    
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
                    TextField("", text: $viewModel.email)
                        .customTextFieldStyle()
                    Text("Password").foregroundStyle(Color.black)
                    TextField("", text: $viewModel.password)
                        .customTextFieldStyle()
                    Button(action: {
                        
                    }){
                        Text("Forgot Password?").foregroundStyle(Color.black)
                    }
                }
                Button("Login"){
                   // navigate = true
                    viewModel.login()
                }
                .customButtonStyle()
                .disabled(viewModel.isLoading)
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
