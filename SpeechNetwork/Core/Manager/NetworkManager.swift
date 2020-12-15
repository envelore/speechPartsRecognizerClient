import Foundation
import Models

enum NetworkResponse: String {
    case success
    case internalError = "Internal error"
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String> {
    case success
    case failure(String)
}

public final class RecognitionNetworkService {
    private let router = Router<TextRecognitionRequest>()
    
    public init() {}
    
    private func send(
        request: TextRecognitionRequest,
        completion: @escaping (RecognitionApiResponse) -> ())
    {
        router.request(request) { data, response, error in
            if error != nil {
                print("Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        return
                    }
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(RecognitionApiResponse.self, from: responseData)
                        DispatchQueue.main.async {
                            completion(apiResponse)
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let networkFailureError):
                    let failResponse = RecognitionApiResponse(
                        status: .internalError,
                        result: .init(
                            speechParts: [],
                            errorMessage: networkFailureError
                        )
                    )
                    DispatchQueue.main.async {
                        completion(failResponse)
                    }
                }
            }
        }
    }
    
    public func recognize(
        request: TextRecognitionRequest,
        completion: @escaping (RecognitionApiResponse) -> ())
    {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.send(request: request, completion: completion)
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
            case 200...299: return .success
            case 401...500: return .failure(NetworkResponse.internalError.rawValue)
            case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
            case 600: return .failure(NetworkResponse.outdated.rawValue)
            default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
