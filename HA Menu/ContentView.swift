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
                        {index in
                            HStack() {
                                VStack(alignment: .leading) {
                                    Text(serverItems[index])
                                        .font(.title3)
                                    HStack() {
                                        Circle()
                                            .fill(.green)
                                            .frame(width: 10, height: 10)
                                        Text("Connected")
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Label("forward", systemImage: "chevron.right")
                                    .labelStyle(IconOnlyLabelStyle())
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color("BorderColor"), lineWidth: 1)
                            )
                            .background(Color("PanelColor"))
                            .onTapGesture {
                                showSubview(view: AnyView(Text("Subview!").frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white)))
                            }
                            
                            
                            //                            ServerStatusView(serverName: serverItems[index], action: {
                            //                                showSubview(view: AnyView(Text("Subview!").frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white)))
                            //                            })
                            //                            .frame(maxWidth: .infinity, minHeight: 200)
                            
                            //                            Button(action: {
                            //                                    showSubview(view: AnyView(Text("Subview!").frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white)))
                            //                                }, label: {
                            //                                    Text("go to subview")
                            //                                })
                            
                            //                            NavigationLink(destination: ServerView(), tag: serverItems[index], selection: $select)
                            //                            {
                            //                                ServerStatusView(serverName: serverItems[index])
                            //                            }
                        }
                        //                    .listRowBackground(Color.clear)
                        //                    .listRowSeparator(.hidden)
                        
                    }
                    //                .scrollContentBackground(.hidden)
                }
            }
            .toolbar
            {
                Button(action: {})
                {
                    Label("Upload", systemImage: "square.and.arrow.up")
                }
            }
            .navigationTitle("Servers")
            
            HStack {
                Spacer()
                Button("Add Server\u{2026}") {
                    
                }
            }
            
            Toggle(isOn: .constant(false)) {
                Text("Start at login")
            }
            .toggleStyle(.switch)
            .controlSize(ControlSize.small)
            
            
            //            VStack(alignment: .leading) {
            //                HStack {
            //                    Text("Server")
            //                        .frame(width: 50, alignment: .leading)
            //                    TextField("", text: $server)
            //                }
            //
            //                HStack(alignment: .top) {
            //                    Text("Token")
            //                        .frame(width: 50, alignment: .leading)
            //                    TextField("", text: $token)
            //                        .frame(height: 100)
            //
            //                }
            //            }
            //            .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
            //
            //            HStack {
            //                TextField("", text: $input)
            //                    .textFieldStyle(.roundedBorder)
            //
            //                Button("Add Entity") {
            //                    print("add entity")
            //                }
            //                .padding(.leading, 5)
            //            }
            //            .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
            
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
