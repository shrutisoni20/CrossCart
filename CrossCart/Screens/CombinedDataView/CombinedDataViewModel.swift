//
//  CombinedDataViewModel.swift
//  CrossCart
//  Created by shruti's macbook on 08/05/25.
//

import SwiftUI
import Combine


class CombinedDataViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var error: Error?
    @Published var userProfile : userProfile?
    @Published var accountBalance : accountBalance?
    
    private let combinedDataAPIService = CombinedDataAPIService()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData() {
        isLoading = true
        
        Publishers.CombineLatest(
            combinedDataAPIService.fetchUserProfile(),
            combinedDataAPIService.fetchAccountBalance()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] (userProfile, accountBalance) in
            self?.userProfile = userProfile
            self?.accountBalance = accountBalance
        }
        .store(in: &cancellables)
    }
}
