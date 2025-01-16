//
//  ContentView.swift
//  University
//
//  Created by Trinath Vikkurthi on 1/15/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: UniversityViewModel

    init() {
        if let resolvedViewModel: UniversityViewModel = DIContainer.shared.resolve(UniversityViewModel.self) {
            _viewModel = StateObject(wrappedValue: resolvedViewModel)
        } else {
            fatalError("Dependency injection failed")
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading universities...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(viewModel.universities) { university in
                        VStack(alignment: .leading) {
                            Text(university.name)
                                .font(.headline)
                            if let webPage = university.web_pages.first {
                                Link(webPage, destination: URL(string: webPage)!)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Universities")
            .onAppear {
                viewModel.fetchUniversities()
            }
        }
    }
}

#Preview {
    ContentView()
}
