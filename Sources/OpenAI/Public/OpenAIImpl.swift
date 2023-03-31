//
//  OpenAIImpl.swift
//  
//
//  Created by Sihao Lu on 3/30/23.
//

import Foundation

public final class OpenAIImpl: OpenAI {
    public enum OpenAIError: Error {
        case invalidURL
        case emptyData
    }

    public struct APIError: Error, Decodable {
        public let message: String
        public let type: String
        public let param: String?
        public let code: String?
    }

    public struct APIErrorResponse: Error, Decodable {
        public let error: APIError
    }

    private let apiToken: String
    private let session: URLSessionProtocol

    public init(
        apiToken: String,
        session: URLSessionProtocol = URLSession.shared
    ) {
        self.apiToken = apiToken
        self.session = session
    }
}

public extension OpenAIImpl {
    func completions(query: CompletionsQuery, timeoutInterval: TimeInterval = 60.0, completion: @escaping (Result<CompletionsResult, Error>) -> Void) {
        performRequest(request: Request<CompletionsResult>(body: query, url: .completions, timeoutInterval: timeoutInterval), completion: completion)
    }
}

public extension OpenAIImpl {
    func images(query: ImagesQuery, timeoutInterval: TimeInterval = 60.0, completion: @escaping (Result<ImagesResult, Error>) -> Void) {
        performRequest(request: Request<ImagesResult>(body: query, url: .images, timeoutInterval: timeoutInterval), completion: completion)
    }
}

public extension OpenAIImpl {
    func embeddings(query: EmbeddingsQuery, timeoutInterval: TimeInterval = 60.0, completion: @escaping (Result<EmbeddingsResult, Error>) -> Void) {
        performRequest(request: Request<EmbeddingsResult>(body: query, url: .embeddings, timeoutInterval: timeoutInterval), completion: completion)
    }
}

public extension OpenAIImpl {
    func chats(query: ChatQuery, timeoutInterval: TimeInterval = 60.0, completion: @escaping (Result<ChatResult, Error>) -> Void) {
        performRequest(request: Request<ChatResult>(body: query, url: .chats, timeoutInterval: timeoutInterval), completion: completion)
    }
}

extension OpenAIImpl {
    func performRequest<ResultType: Codable>(request: Request<ResultType>, completion: @escaping (Result<ResultType, Error>) -> Void) {
        do {
            let request = try OpenAIImpl.makeRequest(query: request.body, url: request.url, timeoutInterval: request.timeoutInterval, apiToken: apiToken)
            let task = session.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(OpenAIError.emptyData))
                    return
                }

                var apiError: Error? = nil
                do {
                    let decoded = try JSONDecoder().decode(ResultType.self, from: data)
                    completion(.success(decoded))
                } catch {
                    apiError = error
                }

                if let apiError = apiError {
                    do {
                        let decoded = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                        completion(.failure(decoded))
                    } catch {
                        completion(.failure(apiError))
                    }
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
            return
        }
    }

    static func makeRequest(query: Codable, url: URL, timeoutInterval: TimeInterval, apiToken: String) throws -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(query)
        return request
    }
}
