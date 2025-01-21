//
//  UniversityViewModel.swift
//  University
//
//  Created by Trinath Vikkurthi on 1/15/25.
//
import Foundation
class UniversityViewModel: ObservableObject {
    @Published var universities: [University] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let apiService: ApiServiceProtocol

    init(apiService: ApiServiceProtocol) {
        self.apiService = apiService
    }

    func fetchUniversities() {
        isLoading = true
        errorMessage = nil

        apiService.fetchUniversities { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let universities):
                    self?.universities = universities
  
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch universities: \(error.localizedDescription)"
                }
            }
        }
    }
}
