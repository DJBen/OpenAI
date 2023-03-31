//
//  URLSessionProtocol.swift
//  
//
//  Created by Sihao Lu on 3/30/23.
//

import Foundation

/// A protocol representing an abstracted URLSession.
/// This allows us to create session mocks.
public protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol
}

public protocol URLSessionDataTaskProtocol {
    func resume()
}
