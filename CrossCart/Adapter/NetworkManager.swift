//
//  NetworkManager.swift
//  CrossCart
//
//  Created by shruti's macbook on 25/04/25.

import Foundation
import Combine

enum APIErrorCode: Error {
    case invalidUrl
    case invalidResponse
    case encodingFailed
    case decodingFailed
    case serverError
    case unknown
    case decodingError
}

struct APIError : Error {
    var errorCode : APIErrorCode
    var errorDetail: String?
    
    init(errorCode: APIErrorCode, errorDetail: String? = nil) {
        self.errorCode = errorCode
        self.errorDetail = errorDetail
    }
}

class NetworkManager {
    
    static let shared = NetworkManager()
   // private init() {}
    
    func post<T:Decodable, U: Encodable>(
        url: String,
        method: HTTPMethod,
        body: U,
        responseType: T.Type
    ) -> AnyPublisher<T,APIError> {
        
        guard let url = URL(string: url) else {
            let error = APIError(errorCode: APIErrorCode.invalidUrl, errorDetail: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoded = try JSONEncoder().encode(body)
            request.httpBody = encoded
        } catch {
            let error = APIError(errorCode: APIErrorCode.encodingFailed, errorDetail: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .mapError { error in
//                print("Network error before flatMap: \(error)")
//                return APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
//            }
//            .flatMap {  result -> AnyPublisher<T, APIError> in
//                let data = result.data
//                let response = result.response
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
//                    return Fail(error: error).eraseToAnyPublisher().eraseToAnyPublisher()
//                }
//                
//                return Just(data)
//                    .decode(type: T.self, decoder: JSONDecoder())
//                    .mapError{ error in
//                        print("Decoding Error: \(error.localizedDescription)")
//                        return APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
//                    }.eraseToAnyPublisher()
//                
//            }.eraseToAnyPublisher()
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { output in
                if let httpResponse = output.response as? HTTPURLResponse {
                    print("Status Code: \(httpResponse.statusCode)")
                }
            })
            .mapError { error in
                print("Transport error: \(error)")
                return APIError(errorCode: .invalidResponse, errorDetail: error.localizedDescription)
            }
            .flatMap { result -> AnyPublisher<T, APIError> in
                let data = result.data

                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { error in
                        print("Decoding error: \(error)")
                        return APIError(errorCode: .invalidResponse, errorDetail: error.localizedDescription)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

