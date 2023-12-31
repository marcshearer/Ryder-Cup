//
//  ContentView.swift
//  Ryder Cup
//
//  Created by Marc Shearer on 18/08/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var event = Event()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
