import UIKit

public final class Document: UIDocument {
    public var userText: String?
    
    override public func contents(forType typeName: String) throws -> Any {
        if let content = userText {
            let length = content.lengthOfBytes(using: String.Encoding.utf8)
            return NSData(bytes:content, length: length)
        } else {
            return Data()
        }
    }
    
    override public func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContent = contents as? Data {
            userText = NSString(
                bytes: (contents as AnyObject).bytes,
                length: userContent.count,
                encoding: String.Encoding.utf8.rawValue) as String?
        }
    }
}
