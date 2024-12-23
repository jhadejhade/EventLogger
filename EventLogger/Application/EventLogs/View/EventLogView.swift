//
//  EventLogView.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

import SwiftUI

struct EventLogView<T: EventLogViewModelProtocol>: View {
    
    @StateObject var viewModel: T
    
    var body: some View {
        if viewModel.hasError {
            VStack(spacing: 16) {
                Text("Something went wrong")
                
                Button("Try again") {
                    viewModel.fetchEvents()
                }
            }
        } else {
            List {
                ForEach(viewModel.events, id: \.createdAt) { item in
                    Text(viewModel.getFormattedString(for: item))
                }
                
                if viewModel.hasMoreData {
                    HStack {
                        Spacer()
                        
                        ProgressView()
                        
                        Spacer()
                    }
                    .onAppear(perform: viewModel.bumpPage)
                }
            }
            .onAppear(perform: viewModel.fetchEvents)
        }
    }
}

#Preview {
    let viewModel = EventLogViewModel()
    EventLogView(viewModel: viewModel)
}
