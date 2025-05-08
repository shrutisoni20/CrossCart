//
//  LoginViewModel.swift
//  CrossCart
//
//  Created by shruti's macbook on 25/04/25.
//

import SwiftUI

class LoginViewModel : ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var loginMessage: String?
    @Published var navigate = false
    
    
    private let loginAPIService = LoginAPIService()
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "self matches %@", emailRegex).evaluate(with: email)
    }
    
    var isValidPassword: Bool {
           return password.count >= 6
       }
    
    func login() {
//        guard isValidEmail else {   
//            errorMessage = "Invalid email address"
//            return
//        }
//     
//        guard isValidPassword else {
//            errorMessage = "Invalid password"
//            return
//        }
        
        errorMessage = nil
        isLoading = true
        
        loginAPIService.login(email: "eve.holt@reqres.in",
                               password: "cityslicka") { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                switch result {
                case .success(let response):
                    self?.loginMessage = "Logged in! Token: \(response.token)"
                    self?.isLoggedIn = true
                    self?.isLoading = false
                case .failure(let error):
                    self?.loginMessage = error.localizedDescription
                    self?.isLoggedIn   = false
                    self?.isLoading    = false
                }
            }
        }
    }
}

