import UIKit

// MARK: - UITextView
extension UITextView {
   var visibleRange: NSRange? {
        guard let start = closestPosition(to: contentOffset),
            let range = characterRange(
                at: CGPoint(
                    x: contentOffset.x + bounds.maxX,
                    y: contentOffset.y + bounds.maxY
                )
            )
        else { return nil }
        let end = range.end
        return NSMakeRange(
            offset(from: beginningOfDocument, to: start),
            offset(from: start, to: end)
        )
    }
}

// MARK: - String
extension String {
    func words() -> [String] {
        var words = [String]()
        if let selfRange = range(of: self) {
            self.enumerateSubstrings(in: selfRange, options: .byWords) { (substring, _, _, _) -> () in
                if let string = substring {
                    words.append(string)
                }
            }
        }
        
        return words
    }
    
    func wordsWithRanges() -> [(String, Range<String.Index>)] {
        var words = [(String, Range<String.Index>)]()
        if let selfRange = range(of: self) {
            self.enumerateSubstrings(in: selfRange, options: .byWords) { (substring, _, range, _) -> () in
                if let string = substring {
                    words.append((string, range))
                }
            }
        }
        
        return words
    }
    
    func rangeFromNSRange(nsRange: NSRange) -> Range<String.Index>? {
        return Range(nsRange, in: self)
    }
}

// MARK: - Range
extension RangeExpression where Bound == String.Index  {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}
