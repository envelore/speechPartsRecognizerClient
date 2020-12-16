import Models
import UIKit
import SpeechNetwork
import Foundation

final class DocumentViewController: UIViewController, DocumentViewInput {
    // MARK: - Properties
    private var document: Document?
    private var contentView = DocumentView()
    private var networkService = RecognitionNetworkService()
    
    // MARK: - UIViewController lifecycle
    override func loadView() {
        view = contentView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open { [weak self] success in
            if success {
                self?.setData(data: self?.document)
            } else {
                print("Error: document opening failed")
                self?.dismissDocumentViewController()
            }
        }
    }
    
    // MARK: - DocumentViewInput
    func setData(data document: Document?) {
        self.document = document
        setUpView()
    }
    
    // MARK: - Private
    private func setUpView() {
        if let text = document?.userText {
            contentView.setViewData(text: NSAttributedString(string: text), needReload: true)
        }
        contentView.onClose = { [weak self] in
            self?.dismissDocumentViewController()
        }
        contentView.onDidScroll = { [weak self] range, string in
            if let string = string,
               let words = self?.detectWordsIn(string: string) {
                let request = TextRecognitionRequest(words: words)
                self?.networkService.recognize(request: request) { result in
                    self?.process(range: range, result: result)
                }
            }
        }
        
    }
    
    private func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
    
    private func process(range: NSRange, result: RecognitionApiResponse) {
        if result.result.isError,
           let message = result.result.errorMessage {
            showError(error: message)
            return
        }
        
        guard let previousText = document?.userText,
              let range = previousText.rangeFromNSRange(nsRange: range),
              let speechParts = result.result.speechParts else { return }
        let attributedString = NSMutableAttributedString(string: previousText)
        
        var index = 0
        previousText.enumerateSubstrings(in: range, options: .byWords) { (substring, _, range, _) -> () in
            if substring != nil, index < speechParts.count {
                let color: UIColor
                switch speechParts[index] {
                case .noun:
                    color = .blue
                case .verb:
                    color = .red
                case .adjective:
                    color = .magenta
                default:
                    color = .black
                }
                attributedString.setAttributes([.foregroundColor: color], range: range.nsRange(in: previousText))
                index += 1
            }
        }
        contentView.setViewData(text: attributedString, needReload: false)
    }
    
    private func detectWordsIn(string: String) -> [String] {
        return string.words()
    }
    
    private func showError(error: String) {
        contentView.showError(text: error)
    }
}
