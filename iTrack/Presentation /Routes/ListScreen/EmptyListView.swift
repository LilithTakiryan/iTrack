//
//  EmptyListView.swift
//  iTrack
//
//  Created by lilit on 30.07.26.
//

import SwiftUI

struct EmptyListView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 44))
            
            Text("No routes yet")
                .font(.title)
            
            Button("Start a new route") {
                dismiss()
            }
        }
    }
}
