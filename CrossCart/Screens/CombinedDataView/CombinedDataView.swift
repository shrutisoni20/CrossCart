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
                       if let api1 = viewModel.api1Data {
                           Text("Name: \(api1.name)")
                           Text("Email: \(api1.email)")
                       }
                       if let api2 = viewModel.api2Data {
                           Text("Balance: \(api2.balance)")
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
