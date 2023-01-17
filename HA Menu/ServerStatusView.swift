//
//  ServerStatusView.swift
//  HA Menu
//
//  Created by Andrew Jackson on 16/01/2023.
//

import SwiftUI

struct ServerStatusView: View {
    
    var serverName: String
    var action: () -> Void
    
    var body: some View {
        Button {
            self.action()
        } label: {
            VStack(alignment: .leading) {
                Text(serverName)
                    .font(.title3)
                HStack() {
                    Circle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                    Text("Connected")
                        .font(.caption)
                }
                
//                Label("forward", systemImage: "chevron.right")
            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding()
//            .overlay(
//                RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color("BorderColor"), lineWidth: 1)
//            )
            .background(Color("PanelColor"))
        }
    }
}

struct ServerStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ServerStatusView(serverName: "Server Test", action: {})
    }
}
