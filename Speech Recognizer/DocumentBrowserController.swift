import UIKit
import Models

class DocumentBrowserViewController:
    UIDocumentBrowserViewController,
    UIDocumentBrowserViewControllerDelegate
{
    // MARK: - UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
    }
    
    // MARK: - UIDocumentBrowserViewControllerDelegate
    func documentBrowser(
        _ controller: UIDocumentBrowserViewController,
        didPickDocumentsAt documentURLs: [URL])
    {
        guard let sourceURL = documentURLs.first else { return }
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(
        _ controller: UIDocumentBrowserViewController,
        failedToImportDocumentAt documentURL: URL,
        error: Error?)
    {
        // Make sure to handle the failed import appropriately,
        // e.g., by presenting an error message to the user.
    }
    
    // MARK: - Document Presentation
    func presentDocument(at documentURL: URL) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController")
            as? DocumentViewController {
            documentViewController.setData(data: Document(fileURL: documentURL))
            documentViewController.modalPresentationStyle = .fullScreen
            present(documentViewController, animated: true, completion: nil)
        }
    }
}

