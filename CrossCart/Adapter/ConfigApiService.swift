//
//  ConfigApiService.swift
//  CrossCart
//
//  Created by shruti's macbook on 25/04/25.
//

import Foundation
import SwiftUI
import Combine

class ConfigApiService {
    
    static let shared = ConfigApiService()
    private init() {}
    private var cancellable = Set<AnyCancellable>()
    
}
