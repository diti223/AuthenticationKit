//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation
import SwiftUI

extension View {
    func alert(message: Binding<String?>) -> some View {
        self.alert(
            message.wrappedValue ?? "",
            isPresented: message.map(
                get: { $0 != nil },
                set: { _ in nil }
            ),
            actions: {}
        )
    }
}

extension Binding {
    func map<NewValue>(
        get transform: @escaping (Value) -> NewValue,
        set reverseTransform: @escaping (NewValue) -> Value
    ) -> Binding<NewValue> {
        Binding<NewValue>(
            get: { transform(self.wrappedValue) },
            set: { newValue in self.wrappedValue = reverseTransform(newValue) }
        )
    }
}
