//
//  ContentView.swift
//  HA Menu
//
//  Created by Andrew Jackson on 08/05/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State var server: String = ""
    @State var token: String = ""
    @State var input: String = ""
    
    
    @State private var currentSubview = AnyView(ServerView())
    @State private var showingSubview = false
    
    
    var serverItems = ["Server 1", "Server 2", "Server 3",  "Server 4",  "Server 5"]
    @State var select: String? = "Server 1"
    
    var body: some View {
        VStack(alignment: .leading){
            
            StackNavigationView(currentSubview: $currentSubview, showingSubview: $showingSubview)
            {
                ScrollView {
                    LazyVStack
                    {
                        ForEach((0..<serverItems.count), id: \.self)
                        {
                            index in
                            ServerStatusView(serverName: serverItems[index])
                                .onTapGesture {
                                    select = serverItems[index]
                                    showSubview(view: AnyView(ServerView(serverName: serverItems[index]).frame(maxWidth: .infinity, maxHeight: .infinity)))
                                }
                        }
                    }
                }
                
                HStack {
                    Toggle(isOn: .constant(false)) {
                        Text("Start at login")
                    }
                    .toggleStyle(.switch)
                    .controlSize(ControlSize.small)
                    
                    Spacer()
                    
                    Button("Add Server\u{2026}") {
                        
                    }
                }
                
            }
            .toolbar
            {
                Button(action: {})
                {
                    Label("Upload", systemImage: "square.and.arrow.up")
                }
            }
            .navigationTitle( (showingSubview ? select! : "HA Menu") )
            
            Spacer()
        }
        .padding(.all)
    }
    
    private func showSubview(view: AnyView) {
        withAnimation(.easeOut(duration: 0.3)) {
            currentSubview = view
            showingSubview = true
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
