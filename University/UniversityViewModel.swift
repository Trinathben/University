//
//  UniversityViewModel.swift
//  University
//
//  Created by Trinath Vikkurthi on 1/15/25.
//
import Foundation
import Alamofire

class UniversityViewModel: ObservableObject {
    @Published var universities: [University] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    let apiUrl = "http://universities.hipolabs.com/search?country=United+States"
    let sampleData = """
    [
        {
            "name": "Marywood University",
            "domains": ["marywood.edu"],
            "web_pages": ["http://www.marywood.edu"],
            "alpha_two_code": "US",
            "country": "United States",
            "state-province": null
        },
        {
            "name": "Lindenwood University",
            "domains": ["lindenwood.edu"],
            "web_pages": ["http://www.lindenwood.edu/"],
            "alpha_two_code": "US",
            "country": "United States",
            "state-province": null
        }
    ]
    """


    func fetchUniversities() {
        isLoading = true
        errorMessage = nil

   /* AF.request(apiUrl).validate().responseDecodable(of: [University].self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.universities = Array(data.prefix(50)) // Get only the first 50
                case .failure(let error):
                    self.errorMessage = "Failed to fetch universities: \(error.localizedDescription)"
                }
            }
        } */
       DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulating network delay
            let decoder = JSONDecoder()
           if let data = self.sampleData.data(using: .utf8),
                   let universities = try? decoder.decode([University].self, from: data) {
                    self.universities = universities
                    self.isLoading = false
                } else {
                    self.errorMessage = "Failed to load data"
                    self.isLoading = false
                }
            } 
        
    }
}
