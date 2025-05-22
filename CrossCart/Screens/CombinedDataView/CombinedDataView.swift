//
//  CombinedDataView.swift
//  CrossCart
//
//  Created by shruti's macbook on 07/05/25.
//

import SwiftUI

struct CombinedDataView: View {
    @StateObject private var viewModel = CombinedDataViewModel()
    
        var body: some View {
               VStack {
                   if viewModel.isLoading {
                       ProgressView()
                   } else if let error = viewModel.error {
                       Text("Error: \(error.localizedDescription)")
                   } else {
                       if let userProfile = viewModel.userProfile {
                           Text("Name: \(userProfile.name)")
                           Text("Email: \(userProfile.email)")
                       }
                       if let accountBalance = viewModel.accountBalance {
                           Text("Balance: \(accountBalance.balance)")
                       }
                   }
               }
               .onAppear {
                   viewModel.fetchData()
               }
           }
       }
#Preview {
    CombinedDataView()
}
