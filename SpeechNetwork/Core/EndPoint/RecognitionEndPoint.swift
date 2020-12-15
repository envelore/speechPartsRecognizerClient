import Foundation
import Models

enum NetworkEnvironment {
    case qa
    case production
    case staging
}

public class TextRecognitionRequest {
    private let enviromentBase = NetworkEnvironment.production
    var bodyParameters: Parameters?
    
    public init(words: [String]) {
        var dictionary = [String: Any]()
        for (index, word) in words.enumerated() {
            dictionary["word[\(index)]"] = word
        }
        bodyParameters = dictionary
    }
}

extension TextRecognitionRequest: EndPointType {
    var environmentBaseURL: String {
        switch enviromentBase {
            case .production: return "https://yandex.ru/"
            case .qa: return "https://gubanov.ru/branch/"
            case .staging: return "https://gubanov.ru/master/"
        }
    }
    
    public var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    public var path: String {
        "api/1/speechPart/detect"
    }
    
    public var httpMethod: HTTPMethod {
        return .post
    }
    
    public var task: HTTPTask {
        return .requestParameters(
            bodyParameters: bodyParameters,
            bodyEncoding: .jsonEncoding,
            urlParameters: [
                "api_key": ""
            ]
        )
    }
    
    public var headers: HTTPHeaders? {
        return nil
    }
}


