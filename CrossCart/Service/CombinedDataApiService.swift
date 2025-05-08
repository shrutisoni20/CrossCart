//
//  CombinedDataApiService.swift
//  CrossCart
//
//  Created by shruti's macbook on 08/05/25.
//

import Foundation
import Combine

struct userProfile: Decodable {
   
    let name: String
    let email: String
}
struct accountBalance: Decodable {
    
    let balance: Double
}

class CombinedDataAPIService {
    
    private var cancellables =  Set<AnyCancellable>()
    
    func fetchAPI1() -> AnyPublisher<userProfile, Error> {
            let url = URL(string: "https://c2ec-2409-40d4-10c3-d5fd-d187-c176-cd2a-9691.ngrok-free.app/service/api/user/profile")!
         return URLSession.shared.dataTaskPublisher(for: url)
               .tryMap { output in
                   let rawString = String(data: output.data, encoding: .utf8)!
                   print("Raw API1 response: \(rawString)") 
                   return output.data
               }
               .decode(type: userProfile.self, decoder: JSONDecoder())
               .eraseToAnyPublisher()
        }
    
    func fetchAPI2() -> AnyPublisher<accountBalance, Error> {
            let url = URL(string: "https://c2ec-2409-40d4-10c3-d5fd-d187-c176-cd2a-9691.ngrok-free.app/service/api/user/balance")!
        return URLSession.shared.dataTaskPublisher(for: url)
               .tryMap { output in
                   let rawString = String(data: output.data, encoding: .utf8)!
                   print("Raw API1 response: \(rawString)")
                   return output.data
               }
              .decode(type: accountBalance.self, decoder: JSONDecoder())
               .eraseToAnyPublisher()
        }
}
