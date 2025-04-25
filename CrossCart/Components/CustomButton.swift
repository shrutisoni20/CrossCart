//
//  CustomButton.swift
//  CrossCart
//
//  Created by shruti's macbook on 24/04/25.
//
import SwiftUI

struct CustomButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .cornerRadius(12)
    }
}

extension View {
    func customButtonStyle() -> some View {
        self.modifier(CustomButtonModifier())
    }
}
