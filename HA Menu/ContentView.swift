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
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Server")
                        .frame(width: 50, alignment: .leading)
                    TextField("", text: $server)
                }
                
                HStack(alignment: .top) {
                    Text("Token")
                        .frame(width: 50, alignment: .leading)
                    TextField("", text: $token)
                        .frame(height: 100)
                    
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
            
            HStack {
                TextField("", text: $input)
                    .textFieldStyle(.roundedBorder)
                
                Button("Add Entity") {
                    print("add entity")
                }
                .padding(.leading, 5)
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
