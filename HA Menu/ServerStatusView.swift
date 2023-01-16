//
//  ServerStatusView.swift
//  HA Menu
//
//  Created by Andrew Jackson on 16/01/2023.
//

import SwiftUI

struct ServerStatusView: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("Server Name")
            Text("Connected")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.green)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

struct ServerStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ServerStatusView()
    }
}
