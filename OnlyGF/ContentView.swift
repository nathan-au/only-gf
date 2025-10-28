//
//  ContentView.swift
//  OnlyGF
//
//  Created by Nathan Au on 2025-10-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "heart.circle")
                .imageScale(.large)
                .foregroundStyle(.blue)
            Text("Welcome to OnlyGF")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
