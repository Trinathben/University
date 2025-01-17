//
//  UniversityViewModel.swift
//  University
//
//  Created by Trinath Vikkurthi on 1/15/25.
//
import Foundation
import Alamofire

class UniversityViewModel: ObservableObject {
    @Published var universities = [University]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let apiUrl = "http://universities.hipolabs.com/search?country=United+States"
    
    func fetchUniversities() {
        isLoading = true
        errorMessage = nil
        
        AF.request(apiUrl).validate().responseDecodable(of: [University].self) {[weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch response.result {
                case .success(let data):
                    self?.universities = Array(data.prefix(50)) // Get only the first 50
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch universities: \(error.localizedDescription)"
                }
            }
        }
    }
}
