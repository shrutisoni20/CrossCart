////
////  Untitled.swift
////  CrossCart
////  Created by shruti's macbook on 14/05/25.
////
//
//import Foundation
//import Combine
////import Pulse
////import PulseUI
////import PulseProxy
//
//class AbstractAPIService {
//  static let shared = AbstractAPIService()
//  private init() {
//   // NetworkLogger.enableProxy()
//  }
//    
//    
//  func get<T: Decodable>(url urlString: String, responseType: T.Type) -> AnyPublisher<T, APIError> {
//    guard let url = URL(string: urlString) else {
//        let error = APIError(errorCode: APIErrorCode.invalidUrl, errorDetail: nil)
//      return Fail(error: error).eraseToAnyPublisher()
//    }
//      
//    return URLSession.shared.dataTaskPublisher(for: url)
//      .mapError { _ in APIError(errorCode: APIErrorCode.networkError, errorDetail: nil) }
//      .flatMap { data, response -> AnyPublisher<T, APIError> in
//        guard let httpResponse = response as? HTTPURLResponse else {
//          let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
//          return Fail(error: error).eraseToAnyPublisher()
//        }
//          
//        if (200...299).contains(httpResponse.statusCode) {
//          return Just(data)
//            .tryMap { data -> T in
//              do {
//                let decoded = try JSONDecoder().decode(T.self, from: data)
//                return decoded
//              } catch let DecodingError.keyNotFound(key, context) {
//                print(":x: Missing key '\(key.stringValue)' at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
//                throw APIError(
//                  errorCode: .decodingFailed,
//                  errorDetail: APIErrorResponse(
//                    status: "DecodingError",
//                    message: "Missing key: \(key.stringValue) at \(context.codingPath.map(\.stringValue).joined(separator: "."))",
//                    timestamp: ISO8601DateFormatter().string(from: Date())
//                  )
//                )
//              } catch let DecodingError.typeMismatch(type, context) {
//                throw APIError(
//                  errorCode: .decodingFailed,
//                  errorDetail: APIErrorResponse(
//                    status: "DecodingError",
//                    message: "Type mismatch for type \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))",
//                    timestamp: ISO8601DateFormatter().string(from: Date())
//                  )
//                )
//              } catch let DecodingError.valueNotFound(type, context) {
//                throw APIError(
//                  errorCode: .decodingFailed,
//                  errorDetail: APIErrorResponse(
//                    status: "DecodingError",
//                    message: "Expected value of type \(type) not found at \(context.codingPath.map(\.stringValue).joined(separator: "."))",
//                    timestamp: ISO8601DateFormatter().string(from: Date())
//                  )
//                )
//              } catch let DecodingError.dataCorrupted(context) {
//                throw APIError(
//                  errorCode: .decodingFailed,
//                  errorDetail: APIErrorResponse(
//                    status: "DecodingError",
//                    message: "Data corrupted: \(context.debugDescription)",
//                    timestamp: ISO8601DateFormatter().string(from: Date())
//                  )
//                )
//              } catch {
//                if let jsonString = String(data: data, encoding: .utf8) {
//                  print(":warning: Raw JSON Response: \(jsonString)")
//                }
//                throw APIError(
//                  errorCode: .decodingFailed,
//                  errorDetail: APIErrorResponse(
//                    status: "UnknownError",
//                    message: error.localizedDescription,
//                    timestamp: ISO8601DateFormatter().string(from: Date())
//                  )
//                )
//              }
//            }
//            .mapError { error in
//              return error as? APIError ?? APIError(
//                errorCode: .decodingError,
//                errorDetail: APIErrorResponse(
//                  status: "UnknownError",
//                  message: error.localizedDescription,
//                  timestamp: ISO8601DateFormatter().string(from: Date())
//                )
//              )
//            }
//            .eraseToAnyPublisher()
//        }
//       else {
//          if let jsonString = String(data: data, encoding: .utf8) {
//                print("Raw JSON Response: \(jsonString)") // :white_tick: Prints data as a String
//              } else {
//                print("Failed to convert Data to String") // :white_tick: Handles encoding issues
//              }
//          if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
//            let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: errorResponse)
//            return Fail(error: error)
//                .eraseToAnyPublisher()
//          } else {
//            let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
//            return Fail(error: error).eraseToAnyPublisher()
//          }
//        }
//      }
//      .eraseToAnyPublisher()
//  }
// 
//    func post<T: Decodable, U: Encodable>(
//    url urlString: String,
//    method: HTTPMethod,
//    body: U,
//    responseType: T.Type
//  ) -> AnyPublisher<T, APIError> {
//    guard let url = URL(string: urlString) else {
//      let error = APIError(errorCode: APIErrorCode.invalidURL, errorDetail: nil)
//      return Fail(error: error).eraseToAnyPublisher()
//    }
//    var request = URLRequest(url: url)
//    request.httpMethod = method.rawValue
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.timeoutInterval = 600
//    do {
//      request.httpBody = try JSONEncoder().encode(body)
//    } catch {
//      let error = APIError(errorCode: APIErrorCode.encodingFailed, errorDetail: nil)
//      return Fail(error: error).eraseToAnyPublisher()
//    }
//    return URLSession.shared.dataTaskPublisher(for: request)
//      .mapError { _ in APIError(errorCode: APIErrorCode.networkError, errorDetail: nil) }
//      .flatMap { data, response -> AnyPublisher<T, APIError> in
//        guard let httpResponse = response as? HTTPURLResponse else {
//          let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
//          return Fail(error: error).eraseToAnyPublisher()
//        }
//        if (200...299).contains(httpResponse.statusCode) {
//          if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw JSON Response: \(jsonString)") // :white_tick: Prints data as a String
//            if T.self == String.self {
//              return Just(jsonString as! T) // Force-cast because we checked type already
//                   .setFailureType(to: APIError.self)
//                   .eraseToAnyPublisher()
//            }
//          } else {
//            print("Failed to convert Data to String") // :white_tick: Handles encoding issues
//          }
//          return Just(data)
//            .decode(type: T.self, decoder: JSONDecoder())
//            .mapError { error in
//              print("Decoding error: \(error.localizedDescription)")
//              return APIError(errorCode: APIErrorCode.decodingFailed, errorDetail: nil)
//            }
//            .eraseToAnyPublisher()
//        } else {
//          if let jsonString = String(data: data, encoding: .utf8) {
//                print("Raw JSON Response: \(jsonString)") // :white_tick: Prints data as a String
//              } else {
//                print("Failed to convert Data to String") // :white_tick: Handles encoding issues
//              }
//          if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
//            let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: errorResponse)
//            return Fail(error: error)
//                .eraseToAnyPublisher()
//          } else {
//            let error = APIError(errorCode: APIErrorCode.invalidResponse, errorDetail: nil)
//            return Fail(error: error).eraseToAnyPublisher()
//          }
//        }
//      }
//      .eraseToAnyPublisher()
//  }
//}
