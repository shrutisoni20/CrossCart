//
//  CustomTextField.swift
//  CrossCart
//
//  Created by shruti's macbook on 24/04/25.
//

import SwiftUI

struct CustomTextFieldModifier : ViewModifier {
   
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .foregroundStyle(Color.black)
    }
}

extension View {
    func customTextFieldStyle() -> some View {
        self.modifier(CustomTextFieldModifier())
    }
}
