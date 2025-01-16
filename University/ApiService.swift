//
//  ApiService.swift
//  University
//
//  Created by Trinath Vikkurthi on 1/20/25.
//

import Foundation
import Alamofire

protocol ApiServiceProtocol {
    func fetchUniversities(completion: @escaping (Result<[University], Error>) -> Void)
}

class ApiService: ApiServiceProtocol {
    private let apiUrl = "http://universities.hipolabs.com/search?country=United+States"

    func fetchUniversities(completion: @escaping (Result<[University], Error>) -> Void) {
        AF.request(apiUrl).responseDecodable(of: [University].self) { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    completion(.success(Array(data.prefix(50))))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

