//
//  Untitled.swift
//  CrossCart
//
//  Created by shruti's macbook on 19/05/25.
//

import Foundation

struct LibModel {
    
    var brazeObj = Braze.shared
    
    func create() throws -> PaypalCatalogResponse {
        do {
            let result = try brazeObj.brazeCreateCamp(brazeObj: brazeObj)
            print("Valid data: \(String(describing: result))")
            return PaypalCatalogResponse(id: UUID().uuidString, title: result ?? "")
        } catch BrazeValidationError.invalidTitle {
            print("Invalid")
            throw PaypalCatalogError(message: "Invalid Title", code: 400)
        } catch BrazeValidationError.invalidDescription {
            print("Description is Invalid")
            throw PaypalCatalogError(message: "Invalid Description", code: 400)
        } catch {
            throw PaypalCatalogError(message: "Unknown Error Occurred.", code: 400)
        }
        
    }
}

struct PaypalCatalogResponse: Codable {
    let id: String
    let title: String
}

struct PaypalCatalogError: Error {
    var message: String
    var code: Int
}

class Braze {
    
    var title: String?
    var description: String?
    var summary: String?
    
    static let shared = Braze()
    
    private  init() {}
    
    func brazeCreateCamp(brazeObj : Braze ) throws -> String? {
        
        if let title = brazeObj.title {
            if(title.count >= 3 && title.count <= 10) {
                print("Title is valid")
                return title
            } else {
                print("Invalid")
                throw BrazeValidationError.invalidTitle
            }
        }
        if let description = brazeObj.description {
            if(description.count >= 10 && description.count <= 100) {
                print("Description is valid")
                return description
            } else {
                print("Invalid")
                throw BrazeValidationError.invalidDescription
            }
        }
        throw BrazeValidationError.missingData
    }
    
    func brazeModifyCamp(libModel : LibModel) {
        
    }
    
    func brazeDeleteCamp(libModel : LibModel) {
        
    }
    
}

enum BrazeValidationError: Error {
    case invalidTitle
    case invalidDescription
    case missingData
}
