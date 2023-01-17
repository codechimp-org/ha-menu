//
//  ServerView.swift
//  HA Menu
//
//  Created by Andrew Jackson on 17/01/2023.
//

import SwiftUI

struct ServerView: View {
    
    @State var serverName: String = ""
    @State var serverUrl: String = ""
    @State var serverToken: String = ""
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                
                HStack() {
                    Text("Server Name:")
                        .frame(minWidth: 100, alignment: .leading)
                    TextField("Enter server friendly name", text: $serverName)
                }
                
                HStack() {
                    Text("Server URL:")
                        .frame(minWidth: 100, alignment: .leading)
                    TextField("Enter server url", text: $serverUrl)
                }
                
                HStack() {
                    Text("Token:")
                        .frame(minWidth: 100, alignment: .leading)
                    TextField("Enter server token", text: $serverToken)
                }
                
                HStack(alignment: .center) {
                    HStack(alignment: .center) {
                        Circle()
                            .fill(Color("StatusOKColor"))
                            .frame(width: 10, height: 10)
                        Text("Connected")
                            .font(.footnote)
                            .foregroundColor(Color("GrayControlColor"))
                    }
                    
                    Spacer()
                    
                    Button("Connect") {
                        
                    }
                }
                
                Spacer()
            }
            
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView(serverName: "Test")
    }
}
