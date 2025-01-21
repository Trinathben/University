//
//  UniversityTests.swift
//  UniversityTests
//
//  Created by Trinath Vikkurthi on 1/15/25.
//
import XCTest
import Alamofire
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import University

class UniversityViewModelTests: XCTestCase {
    var viewModel: UniversityViewModel!
    
    // Sets up the test environment by initializing the ViewModel instance before each test.
    override func setUp() {
        super.setUp()
        viewModel = UniversityViewModel()
    }
    // Cleans up after each test by removing all stubs and deallocating the ViewModel instance.
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        viewModel = nil
        super.tearDown()
    }
    
    // Tests that the ViewModel can successfully fetch university data and update its state.
    func testFetchUniversitiesSuccess() {
        // Stub successful response
        stub(condition: isHost("universities.hipolabs.com")) { _ in
            let universities = [
                ["name": "Harvard University", "web_pages": ["http://harvard.edu"]],
                ["name": "MIT", "web_pages": ["http://mit.edu"]]
            ]
            let data = try! JSONSerialization.data(withJSONObject: universities, options: [])
            return HTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        }
        
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
    
    // Tests that the ViewModel correctly handles an error during data fetching.
    func testFetchUniversitiesFailure() {
        // Stub failure response
        stub(condition: isHost("universities.hipolabs.com")) { _ in
            let errorData = ["error": "Invalid request"]
            let data = try! JSONSerialization.data(withJSONObject: errorData, options: [])
            return HTTPStubsResponse(data: data, statusCode: 400, headers: nil)
        }
        
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
    
    // Tests that the loading state (`isLoading`) is updated correctly during data fetching.
    func testFetchUniversitiesLoadingState() {
        // Stub successful response with delay
        stub(condition: isHost("universities.hipolabs.com")) { _ in
            let universities = [["name": "Harvard University", "web_pages": ["http://harvard.edu"]]]
            let data = try! JSONSerialization.data(withJSONObject: universities, options: [])
            return HTTPStubsResponse(data: data, statusCode: 200, headers: nil).responseTime(1) // Add delay
        }
        
        let expectation = self.expectation(description: "Fetch universities loading state")
        
        viewModel.fetchUniversities()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.viewModel.isLoading, "isLoading should be true while fetching")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(self.viewModel.isLoading, "isLoading should be false after fetching")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
