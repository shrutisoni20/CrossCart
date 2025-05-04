//
//  LoginApiService.swift
//  CrossCart
//
//  Created by shruti's macbook on 02/05/25.
//


import Foundation
import Combine

struct LoginResponse: Decodable {
    let token: String
}

class LoginAPIService {
    private let networkManager = NetworkManager()
    private let url : String? = "https://reqres.in/api/login"
    private var cancellables =  Set<AnyCancellable>()

    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = url else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        }

        let body: [String: String] = [
            "email": email,
            "password": password
        ]

        networkManager.post(url: url, method: HTTPMethod.POST, body: body, responseType: LoginResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Request finished")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }, receiveValue: { response in
                print("Login token: \(response.token)")
            })
            .store(in: &cancellables)
    }
}
