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
    case unauthorized
    case encodingFailed
    case serverError
    case unknown
    case decodingError
    case badRequest
    case forbidden
    case notFound
    case networkError
}

struct APIError : Error {
    var errorCode : APIErrorCode
    var errorDetail: String?
    
    init(errorCode: APIErrorCode, errorDetail: String? = nil) {
        self.errorCode = errorCode
        self.errorDetail = errorDetail
    }
}

struct APIErrorResponse: Decodable {
    let errorMessage: String
}

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    func post<T:Decodable, U: Encodable>(
        url: String,
        method: HTTPMethod,
        body: U,
        responseType: T.Type
    ) -> AnyPublisher<T,APIError> {
        
        guard let url = URL(string: url) else {
            let error = APIError(errorCode: .invalidUrl, errorDetail: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoded = try JSONEncoder().encode(body)
            request.httpBody = encoded
        } catch {
            let error = APIError(errorCode: APIErrorCode.encodingFailed, errorDetail: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> (data: Data, statusCode: Int, response: HTTPURLResponse) in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw APIError(errorCode: .invalidResponse, errorDetail: "Invalid HTTP response")
                }
                let statusCode = httpResponse.statusCode
                let data = output.data
                guard (200...299).contains(statusCode) else {
                    let apiErrorMessage: String = {
                        if let decoded = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                            return decoded.errorMessage
                        } else if let raw = String(data: data, encoding: .utf8) {
                            return raw
                        } else {
                            return "Unknown error"
                        }
                    }()
                    
                    let errorCode: APIErrorCode
                    switch statusCode {
                    case 400: errorCode = .badRequest
                    case 401: errorCode = .unauthorized
                    case 403: errorCode = .forbidden
                    case 404: errorCode = .notFound
                    case 500...599: errorCode = .serverError
                    default: errorCode = .unknown
                    }
                    throw APIError(errorCode: errorCode, errorDetail: apiErrorMessage)
                }
                return (data, statusCode, httpResponse)
            }
            .mapError { error in
                if let urlError = error as? URLError, urlError.code == .timedOut {
                    return APIError(errorCode: .invalidResponse , errorDetail: error.localizedDescription)
                } else if let apiError = error as? APIError {
                    return apiError
                }
                return APIError(errorCode: .invalidResponse, errorDetail: error.localizedDescription)
            }
            .flatMap { result -> AnyPublisher<T, APIError> in
                let data = result.data
                let response = result.response
                let contentType = response.value(forHTTPHeaderField: "Content-Type") ?? ""
                if contentType.contains("application/json") {
                    return Just(data)
                        .decode(type: T.self, decoder: JSONDecoder())
                        .mapError { error in
                            print("Decoding error: \(error)")
                            return APIError(errorCode: .invalidResponse, errorDetail: error.localizedDescription)
                        }.eraseToAnyPublisher()
                } else {
                    if let rawString = String(data: data, encoding: .utf8) {
                        if let result = rawString as? T {
                            return Just(result)
                                .setFailureType(to: APIError.self)
                                .eraseToAnyPublisher()
                        } else {
                            return Fail(error: APIError(errorCode: .invalidResponse, errorDetail: "Unexpected response format"))
                                .eraseToAnyPublisher()
                        }
                    } else {
                        return Fail(error: APIError(errorCode: .invalidResponse, errorDetail: "Unable to decode response as string"))
                            .eraseToAnyPublisher()
                    }
                }
                
            }.eraseToAnyPublisher()
    }
    
    //GET Method
    func get<T: Decodable>(url: String, responseType: T.Type) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: url) else {
            let error = APIError(errorCode: .invalidUrl, errorDetail: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { _ in APIError(errorCode: APIErrorCode.networkError, errorDetail: nil) }
            .flatMap { data, response -> AnyPublisher<T, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    return Just(data)
                        .tryMap { data -> T in
                            do {
                                let decoded = try JSONDecoder().decode(T.self, from: data)
                                return decoded
                            } catch let DecodingError.keyNotFound(key, context) {
                                print(":x: Missing key '\(key.stringValue)' at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
                                throw APIError(
                                    errorCode: .decodingError,
                                    errorDetail: "Missing key: \(key.stringValue) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                                )
                            }
                            catch let DecodingError.typeMismatch(type, context) {
                                throw APIError(
                                    errorCode: .decodingError,
                                    errorDetail:  "Type mismatch for type \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                                )
                            } catch let DecodingError.valueNotFound(type, context) {
                                throw APIError(
                                    errorCode: .decodingError,
                                    errorDetail:
                                        "Expected value of type \(type) not found at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                                )
                            }
                            catch let DecodingError.dataCorrupted(context) {
                                throw APIError(
                                    errorCode: .decodingError,
                                    errorDetail:
                                        "Data corrupted: \(context.debugDescription)"
                                )
                            } catch {
                                if let jsonString = String(data: data, encoding: .utf8) {
                                    print(":warning: Raw JSON Response: \(jsonString)")
                                }
                                throw APIError(
                                    errorCode: .decodingError,
                                    errorDetail:
                                        error.localizedDescription
                                )
                                
                            }
                        }
                        .mapError { error in
                            if let jsonString = String(data: data, encoding: .utf8) {
                                print("Raw JSON Response: \(jsonString)")
                            } else {
                                print("Failed to convert Data to String")
                            }
                            print("Decoding error: \(error.localizedDescription)")
                            return APIError(errorCode: APIErrorCode.decodingError, errorDetail: nil)
                        }.eraseToAnyPublisher()
                } else {
                    if let jsonString = String(data: data, encoding: .utf8) {
                          print("Raw JSON Response: \(jsonString)") // :white_tick: Prints data as a String
                        } else {
                          print("Failed to convert Data to String") // :white_tick: Handles encoding issues
                        }
                    if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                      let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: "errorResponse")
                      return Fail(error: error)
                          .eraseToAnyPublisher()
                    } else {
                      let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
                      return Fail(error: error).eraseToAnyPublisher()
                    }
                  }
                }
                .eraseToAnyPublisher()
            }
    
    //Error When else part
    
//    else {
//        if let jsonString = String(data: data, encoding: .utf8) {
//                    print("Raw JSON Response: \(jsonString)")  // :white_tick: Prints data as a String
//                } else {
//                    print("Failed to convert Data to String")  // :white_tick: Handles encoding issues
//                }
//          throw APIError(
//            errorCode: .decodingError,
//                         errorDetail:  "UnknownError"
//                         )
//                     
//     }
//    
    
    func performGET<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                print("Raw API1 response: \(String(data: output.data, encoding: .utf8) ?? "")")
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}


