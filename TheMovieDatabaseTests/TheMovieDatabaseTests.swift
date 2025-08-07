//
//  TheMovieDatabaseTests.swift
//  TheMovieDatabaseTests
//
//  Created by Adlan Aufar on 04/08/25.
//

import XCTest
@testable import TheMovieDatabase

final class TheMovieDatabaseTests: XCTestCase {

    let mockApiResponse = ApiResponse(
        page: 1,
        results: [ItemData(
            id: 1,
            originalTitle: "Test Movie",
            originalName: nil,
            posterPath: "/poster.jpg",
            voteAverage: 7.5,
            voteCount: 1234
        )],
        totalPages: 1,
        totalResults: 1
    )
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetMovieListUpdatesItems() {
        let mockRepo = MockMovieAndTvRepository()
        mockRepo.mockApiResponse = ApiResponse(
            page: 1,
            results: [
                ItemData(
                    id: 1,
                    originalTitle: "Test Movie",
                    originalName: nil,
                    posterPath: "/poster.jpg",
                    voteAverage: 7.5,
                    voteCount: 1234
                )
            ],
            totalPages: 1,
            totalResults: 1
        )
        
        let viewModel = HomeViewModel(repository: mockRepo)

        viewModel.getMovieList(endpoint: .popularMovie, page: 1)

        let expectation = XCTestExpectation(description: "Wait for items to update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let items = viewModel.items.value
            XCTAssertEqual(items.count, 1)
            
            if case let .success(movie) = items.first {
                XCTAssertEqual(movie.originalTitle, "Test Movie")
                XCTAssertEqual(movie.voteAverage, 7.5)
            } else {
                XCTFail("Expected .success item but got something else")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
