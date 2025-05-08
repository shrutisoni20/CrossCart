//
//  CombinedDataViewModel.swift
//  CrossCart
//
//  Created by shruti's macbook on 08/05/25.
//

import SwiftUI
import Combine


class CombinedDataViewModel: ObservableObject {
   
    @Published var isLoading = false
    @Published var error: Error?
    @Published var api1Data: userProfile?
    @Published var api2Data: accountBalance?

    private let combinedDataAPIService = CombinedDataAPIService()
    private var cancellables = Set<AnyCancellable>()

    func fetchData() {
        isLoading = true
        
        Publishers.CombineLatest(
            combinedDataAPIService.fetchAPI1(),
            combinedDataAPIService.fetchAPI2()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] (API1, API2) in
            self?.api1Data = API1
            self?.api2Data = API2
        }
        .store(in: &cancellables)
    }
}
