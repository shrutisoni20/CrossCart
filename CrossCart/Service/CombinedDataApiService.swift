//
//  CombinedDataApiService.swift
//  CrossCart
//
//  Created by shruti's macbook on 08/05/25.
//

import Foundation
import Combine

struct userProfile: Codable {
    
    let name: String
    let email: String
}
struct accountBalance: Codable {
    
    let balance: Double
}

class CombinedDataAPIService {
    
    private var cancellables =  Set<AnyCancellable>()
    
    func fetchUserProfile() -> AnyPublisher< userProfile, APIError > {
        let url = "https://c2ec-2409-40d4-10c3-d5fd-d187-c176-cd2a-9691.ngrok-free.app/service/api/user/profile"
        return NetworkManager.shared.get(url: url, responseType: userProfile.self)
    }
    
    func fetchAccountBalance() -> AnyPublisher< accountBalance, APIError > {
        let url =  "https://c2ec-2409-40d4-10c3-d5fd-d187-c176-cd2a-9691.ngrok-free.app/service/api/user/balance"
        return NetworkManager.shared.get(url: url, responseType: accountBalance.self)
    }
    
}
