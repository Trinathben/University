//
//  UniversityTests.swift
//  UniversityTests
//
//  Created by Trinath Vikkurthi on 1/15/25.
//

import XCTest
@testable import University

// MARK: - UniversityViewModelTests

class UniversityViewModelTests: XCTestCase {
    
    var viewModel: UniversityViewModel!
    var mockApiService: MockApiService!

    override func setUp() {
        super.setUp()
        
        // Initialize the mock API service and the view model
        mockApiService = MockApiService()
        viewModel = UniversityViewModel(apiService: mockApiService)
    }

    override func tearDown() {
        viewModel = nil
        mockApiService = nil
        super.tearDown()
    }
    
    func testFetchUniversitiesSuccess() {
        mockApiService.universities = [
            University(name: "Harvard University", domains: ["harvard.edu"], web_pages: ["http://harvard.edu"]),
            University(name: "MIT", domains: ["mit.edu"], web_pages: ["http://mit.edu"])
        ]

        let expectation = self.expectation(description: "Fetch universities success")
        
        viewModel.fetchUniversities()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.isLoading, "isLoading should be false after fetching")
            XCTAssertEqual(self.viewModel.universities.count, 2, "Should load 2 universities")
            XCTAssertNil(self.viewModel.errorMessage, "Error message should be nil on success")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchUniversitiesFailure() {
        mockApiService.shouldReturnError = true
        
        let expectation = self.expectation(description: "Fetch universities failure")
        
        viewModel.fetchUniversities()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.isLoading, "isLoading should be false after failure")
            XCTAssertEqual(self.viewModel.universities.count, 0, "No universities should be loaded")
            XCTAssertNotNil(self.viewModel.errorMessage, "Error message should be set on failure")
            XCTAssertTrue(self.viewModel.errorMessage!.contains("Failed to fetch universities"), "Error message should describe the failure")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchUniversitiesLoadingState() {
        mockApiService.universities = [
            University(name: "Harvard University", domains: ["harvard.edu"], web_pages: ["http://harvard.edu"])
        ]

        let loadingExpectation = self.expectation(description: "isLoading should be true")
        let completionExpectation = self.expectation(description: "isLoading should be false after fetching")

        // Observe changes to isLoading
        let cancellable = viewModel.$isLoading.sink { isLoading in
            if isLoading {
                loadingExpectation.fulfill() // When isLoading becomes true
            }
        }

        // Trigger fetch
        viewModel.fetchUniversities()

        wait(for: [loadingExpectation], timeout: 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.isLoading, "isLoading should be false after fetching")
            completionExpectation.fulfill()
        }

        wait(for: [completionExpectation], timeout: 2)
        cancellable.cancel() // Clean up the observation
    }

}

// MARK: - DIContainerTests

class DIContainerTests: XCTestCase {
    var diContainer: DIContainer!

    override func setUp() {
        super.setUp()
        diContainer = DIContainer.shared
    }

    override func tearDown() {
        diContainer = nil
        super.tearDown()
    }

    func testResolveUniversityViewModel() {
        let resolvedViewModel = diContainer.resolve(UniversityViewModel.self)
        XCTAssertNotNil(resolvedViewModel, "UniversityViewModel should be resolved successfully")
        XCTAssertTrue(resolvedViewModel is UniversityViewModel, "Resolved instance should be of type UniversityViewModel")
    }

    func testResolveApiServiceProtocol() {
        let resolvedApiService = diContainer.resolve(ApiServiceProtocol.self)
        XCTAssertNotNil(resolvedApiService, "ApiServiceProtocol should be resolved successfully")
        XCTAssertTrue(resolvedApiService is ApiService, "Resolved instance should be of type ApiService")
    }

    func testDIContainerSingleton() {
        let anotherContainer = DIContainer.shared
        XCTAssertTrue(diContainer === anotherContainer, "DIContainer.shared should return the same instance")
    }

    func testUniversityViewModelHasCorrectApiService() {
        // Resolve the view model from DIContainer
        let resolvedViewModel = diContainer.resolve(UniversityViewModel.self)
        
        XCTAssertNotNil(resolvedViewModel, "UniversityViewModel should be resolved successfully")
        
        // Inject a mock ApiServiceProtocol to verify it works
        XCTAssertTrue(resolvedViewModel is UniversityViewModel, "Resolved instance should be of type UniversityViewModel")
        
        // Test the behavior indirectly through fetchUniversities()
        let mockApiService = MockApiService()
        mockApiService.universities = [
            University(name: "Test University", domains: ["test.edu"], web_pages: ["http://test.edu"])
        ]
        let testViewModel = UniversityViewModel(apiService: mockApiService)
        testViewModel.fetchUniversities()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(testViewModel.universities.count, 1, "Should fetch universities successfully")
            XCTAssertEqual(testViewModel.universities.first?.name, "Test University", "University name should match")
        }
    }


    func testResolveUnregisteredType() {
        let resolvedUnregistered = diContainer.resolve(String.self)
        XCTAssertNil(resolvedUnregistered, "Resolving an unregistered type should return nil")
    }
}
