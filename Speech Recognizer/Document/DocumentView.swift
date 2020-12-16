import UIKit

final class DocumentView: UIView, UITextViewDelegate {
    // MARK: - Spec
    private final class Spec {
        static let fontSize = CGFloat(48.0)
        static let buttonOffset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 16)
        static let buttonSize = CGSize(width: 34, height: 34)
    }
    
    // MARK: - Subviews
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isPagingEnabled = true
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: Spec.fontSize)
        return textView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "CloseIcon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(onCloseButtonTap), for: .touchUpInside)
        return button
    }()
    
    var onClose: (() -> ())?
    var onDidScroll: ((NSRange, String?) -> ())?
    var onDidAppear: (() -> ())?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(textView)
        addSubview(closeButton)
        
        textView.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame.origin.x = .zero
        textView.frame.origin.y = safeAreaInsets.top
        textView.frame.size = CGSize(
            width: frame.width,
            height: frame.height - safeAreaInsets.top
        )
        
        closeButton.frame = CGRect(
            x: frame.width - Spec.buttonOffset.right - Spec.buttonSize.width,
            y: Spec.buttonOffset.top + safeAreaInsets.top,
            width: Spec.buttonSize.width,
            height: Spec.buttonSize.height
        )
    }
    
    // MARK: - Internal
    func setViewData(text: NSAttributedString, needReload: Bool) {
        textView.attributedText = text
        if needReload {
            handleNewPage()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleNewPage()
    }
    
    func showError(text: String) {
        let errorView = UILabel(
            frame: CGRect(
                x: 16,
                y: frame.height + 60,
                width: frame.width - 32,
                height: 50
            )
        )
        errorView.text = text
        errorView.textAlignment = .center
        errorView.textColor = .white
        errorView.backgroundColor = .black
        addSubview(errorView)
        
        UIView.animate(
            withDuration: 0.5,
            animations: {
                errorView.frame.origin.y -= 130
            },
            completion: { [weak self] _ in
                self?.hideError(toastView: errorView)
            }
        )
    }
    
    // MARK: - Private
    private func handleNewPage() {
        if let range = textView.visibleRange,
           let visibleText = textView.text as NSString? {
            let text = visibleText.substring(with: range)
            onDidScroll?(range, text)
        }
    }
    
    private func hideError(toastView: UIView) {
        UIView.animate(
            withDuration: 0.5,
            delay: 3,
            options: .curveLinear,
            animations: {
                toastView.frame.origin.y += 130
            },
            completion: { _ in
                toastView.removeFromSuperview()
            }
        )
    }
    
    @objc private func onCloseButtonTap() {
        onClose?()
    }
}
