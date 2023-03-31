//
//  MockURLSession.swift
//  
//
//  Created by Sihao Lu on 3/30/23.
//

import Foundation
import OpenAI

class MockURLSession: URLSessionProtocol {
    var nextDataTask = MockURLSessionDataTask {}
    var lastRequest: URLRequest?

    var mockData: Data?

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        lastRequest = request

        let mockResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )

        completionHandler(mockData, mockResponse, nil)
        return nextDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    func resume() {
        closure()
    }
}
