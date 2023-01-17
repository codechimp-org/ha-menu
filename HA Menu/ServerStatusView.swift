//
//  ServerStatusView.swift
//  HA Menu
//
//  Created by Andrew Jackson on 16/01/2023.
//

import SwiftUI

struct ServerStatusView: View {
    
    var serverName: String = ""
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading) {
                Text(serverName)
                    .font(.title3)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: -5, trailing: 0))
                HStack() {
                    Circle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                    Text("Connected")
                        .font(.footnote)
                        .foregroundColor(Color("GrayControlColor"))
                }
            }
            Spacer()
            Label("forward", systemImage: "chevron.right")
                .labelStyle(IconOnlyLabelStyle())
                .foregroundColor(Color("GrayControlColor"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color("BorderColor"), lineWidth: 1)
        )
        .background(Color("PanelColor"))
    }
}

struct ServerStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ServerStatusView(serverName: "Server Test")
    }
}
