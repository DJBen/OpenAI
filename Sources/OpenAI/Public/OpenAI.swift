//
//  OpenAI.swift
//
//
//  Created by Sergii Kryvoblotskyi on 9/18/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol OpenAI {
    /// Given a prompt, the model will return one or more predicted completions, and can also return the
    /// probabilities of alternative tokens at each position.
    /// - Seealso: https://platform.openai.com/docs/api-reference/completions
    /// - Parameters:
    ///   - query: The query to complete the text.
    ///   - timeoutInterval: The time interval.
    ///   - completion: The result closure of the completion.
    func completions(
        query: CompletionsQuery,
        timeoutInterval: TimeInterval,
        completion: @escaping (Result<CompletionsResult, Error>) -> Void
    )

    /// Given a prompt and/or an input image, the model will generate a new image.
    /// - Seealso: https://platform.openai.com/docs/api-reference/images
    /// - Parameters:
    ///   - query: The images query.
    ///   - timeoutInterval: The time interval.
    ///   - completion: The result closure of the image generation.
    func images(
        query: ImagesQuery,
        timeoutInterval: TimeInterval,
        completion: @escaping (Result<ImagesResult, Error>) -> Void
    )

    /// Get a vector representation of a given input that can be easily consumed by machine learning
    /// models and algorithms.
    /// - Seealso: https://platform.openai.com/docs/api-reference/embeddings
    /// - Parameters:
    ///   - query: The embeddings query.
    ///   - timeoutInterval: The timeout interval.
    ///   - completion: The result closure of embeddings.
    func embeddings(
        query: EmbeddingsQuery,
        timeoutInterval: TimeInterval,
        completion: @escaping (Result<EmbeddingsResult, Error>) -> Void
    )

    /// Given a chat conversation, the model will return a chat completion response.
    /// - Parameters:
    ///   - query: The chat query
    ///   - timeoutInterval: The timeout interval.
    ///   - completion: The result closure of chats.
    func chats(
        query: ChatQuery,
        timeoutInterval: TimeInterval,
        completion: @escaping (Result<ChatResult, Error>) -> Void
    )

    // Nested types: need this approach to be able to nest a type in a protocol.
    typealias CompletionsQuery = _CompletionsQuery
    typealias CompletionsResult = _CompletionsResult
    
    typealias ImagesQuery = _ImagesQuery
    typealias ImagesResult = _ImagesResult
    
    typealias EmbeddingsQuery = _EmbeddingsQuery
    typealias EmbeddingsResult = _EmbeddingsResult

    typealias ChatQuery = _ChatQuery
    typealias Chat = _Chat
    typealias ChatResult = _ChatResult
}

///MARK: - Completions

// OpenAI.CompletionsQuery to access the type
public struct _CompletionsQuery: Codable {
    /// ID of the model to use.
    public let model: Model
    /// The prompt(s) to generate completions for, encoded as a string, array of strings, array of tokens, or array of token arrays.
    public let prompt: String
    /// What sampling temperature to use. Higher values means the model will take more risks. Try 0.9 for more creative applications, and 0 (argmax sampling) for ones with a well-defined answer.
    public let temperature: Double?
    /// The maximum number of tokens to generate in the completion.
    public let maxTokens: Int?
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    public let topP: Double?
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
    public let frequencyPenalty: Double?
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
    public let presencePenalty: Double?
    /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    public let stop: [String]?
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    public let user: String?
    
    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case temperature
        case maxTokens = "max_tokens"
        case topP = "top_p"
        case frequencyPenalty = "frequency_penalty"
        case presencePenalty = "presence_penalty"
        case stop
        case user
    }
    
    public init(model: Model, prompt: String, temperature: Double? = nil, maxTokens: Int? = nil, topP: Double? = nil, frequencyPenalty: Double? = nil, presencePenalty: Double? = nil, stop: [String]? = nil, user: String? = nil) {
        self.model = model
        self.prompt = prompt
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.stop = stop
        self.user = user
    }
}

// OpenAI.CompletionsResult to access the type
public struct _CompletionsResult: Codable {
    public struct Choice: Codable {
        public let text: String
        public let index: Int
    }

    public let id: String
    public let object: String
    public let created: TimeInterval
    public let model: Model
    public let choices: [Choice]
}

///MARK: - Images

public struct _ImagesQuery: Codable {
    /// A text description of the desired image(s). The maximum length is 1000 characters.
    public let prompt: String
    /// The number of images to generate. Must be between 1 and 10.
    public let n: Int?
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    public let size: String?

    public init(prompt: String, n: Int?, size: String?) {
        self.prompt = prompt
        self.n = n
        self.size = size
    }
}

public struct _ImagesResult: Codable {
    public struct URLResult: Codable {
        public let url: String
    }

    public let created: TimeInterval
    public let data: [URLResult]

    init(created: TimeInterval, data: [_ImagesResult.URLResult]) {
        self.created = created
        self.data = data
    }
}

///MARK: - Embeddings

public struct _EmbeddingsQuery: Codable {
    /// ID of the model to use.
    public let model: Model
    /// Input text to get embeddings for
    public let input: String

    public init(model: Model, input: String) {
        self.model = model
        self.input = input
    }
}

public struct _EmbeddingsResult: Codable {
    public struct Embedding: Codable {
        public let object: String
        public let embedding: [Double]
        public let index: Int
    }

    public let data: [Embedding]

    init(data: [_EmbeddingsResult.Embedding]) {
        self.data = data
    }
}

///MARK: - Chat

public struct _Chat: Codable {
    public let role: String
    public let content: String

    public enum Role: String {
        case system
        case assistant
        case user
    }

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }

    public init(role: Role, content: String) {
        self.init(role: role.rawValue, content: content)
    }
}

public struct _ChatQuery: Codable {
    /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
    public let model: Model
    /// The messages to generate chat completions for
    public let messages: [OpenAI.Chat]
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and  We generally recommend altering this or top_p but not both.
    public let temperature: Double?
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    public let topP: Double?
    /// How many chat completion choices to generate for each input message.
    public let n: Int?
    /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only `server-sent events` as they become available, with the stream terminated by a data: [DONE] message.
    public let stream: Bool?
    /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    public let stop: [String]?
    /// The maximum number of tokens to generate in the completion.
    public let maxTokens: Int?
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
    public let presencePenalty: Double?
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
    public let frequencyPenalty: Double?
    /// Modify the likelihood of specified tokens appearing in the completion.
    public let logitBias: [String:Int]?
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    public let user: String?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case topP = "top_p"
        case n
        case stream
        case stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case user
    }

    public init(model: Model, messages: [OpenAI.Chat], temperature: Double? = nil, topP: Double? = nil, n: Int? = nil, stream: Bool? = nil, stop: [String]? = nil, maxTokens: Int? = nil, presencePenalty: Double? = nil, frequencyPenalty: Double? = nil, logitBias: [String : Int]? = nil, user: String? = nil) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.topP = topP
        self.n = n
        self.stream = stream
        self.stop = stop
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.logitBias = logitBias
        self.user = user
    }

}

public struct _ChatResult: Codable {
    public struct Choice: Codable {
        public let index: Int
        public let message: OpenAI.Chat
        public let finishReason: String

        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }

    public struct Usage: Codable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }

    public let id: String
    public let object: String
    public let created: TimeInterval
    public let model: Model
    public let choices: [Choice]
    public let usage: Usage

    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case usage
    }

    public init(id: String, object: String, created: TimeInterval, model: Model, choices: [Choice], usage: Usage) {
        self.id = id
        self.object = object
        self.created = created
        self.model = model
        self.choices = choices
        self.usage = usage
    }
}

extension URL {
    static let completions = URL(string: "https://api.openai.com/v1/completions")!
    static let images = URL(string: "https://api.openai.com/v1/images/generations")!
    static let embeddings = URL(string: "https://api.openai.com/v1/embeddings")!
    static let chats = URL(string: "https://api.openai.com/v1/chat/completions")!
}
