//
//  MockApiService.swift
//  UniversityTests
//
//  Created by Sharath Badam on 1/21/25.
//

import Foundation
@testable import University

class MockApiService: ApiServiceProtocol {
    var shouldReturnError = false
    var universities: [University] = []
    
    func fetchUniversities(completion: @escaping (Result<[University], Error>) -> Void) {
        if shouldReturnError {
            let error = NSError(domain: "test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
            completion(.failure(error))
        } else {
            completion(.success(universities))
        }
    }
}
