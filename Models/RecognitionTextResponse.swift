import Foundation

public class RecognitionApiResponse: Decodable {
    public let status: ResponseStatus
    public let result: RecognitionApiResult
    
    private enum MovieApiResponseCodingKeys: String, CodingKey {
        case status
        case result
    }
    
    public init(status: ResponseStatus, result: RecognitionApiResult) {
        self.status = status
        self.result = result
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieApiResponseCodingKeys.self)
        
        status = try container.decode(ResponseStatus.self, forKey: .status)
        result = try container.decode(RecognitionApiResult.self, forKey: .result)
    }
}

public final class RecognitionApiResult: Decodable {
    public let speechParts: [SpeechPart]?
    public let errorMessage: String?
    
    public var isError: Bool {
        !(errorMessage?.isEmpty ?? true)
    }
    
    private enum SpeechPartRecognitionCodingKeys: String, CodingKey {
        case parts
        case message
    }
    
    public init(speechParts: [SpeechPart]?, errorMessage: String?) {
        self.speechParts = speechParts
        self.errorMessage = errorMessage
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SpeechPartRecognitionCodingKeys.self)
        speechParts = try? container.decode([SpeechPart].self, forKey: .parts)
        errorMessage = try? container.decode(String.self, forKey: .message)
    }
}

