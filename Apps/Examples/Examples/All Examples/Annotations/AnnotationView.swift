import Foundation
import UIKit

// `AnnotationView` is a custom `UIView` subclass which is used only for annotation demonstration
final class AnnotationView: UIView {

    var onSelect: ((Bool) -> Void)?
    var onClose: (() -> Void)?

    var selected: Bool = false {
        didSet {
            selectButton.setTitle(selected ? "Deselect" : "Select", for: .normal)
            onSelect?(selected)
        }
    }

    var title: String? {
        get { centerLabel.text }
        set { centerLabel.text = newValue }
    }

    lazy var centerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("X", for: .normal)
        return button
    }()
    lazy var selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setTitle("Select", for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.cornerRadius = 8

        let hStack = UIStackView(arrangedSubviews: [centerLabel, closeButton])
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.spacing = 4

        addSubview(hStack)
        addSubview(selectButton)
        
        let vGuide = UILayoutGuide()
        addLayoutGuide(vGuide)
        
        NSLayoutConstraint.activate([
            vGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            vGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            vGuide.topAnchor.constraint(equalTo: topAnchor),
            vGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            hStack.centerXAnchor.constraint(equalTo: vGuide.centerXAnchor),
            hStack.widthAnchor.constraint(equalTo: vGuide.widthAnchor),
            hStack.topAnchor.constraint(equalTo: vGuide.topAnchor),
            
            selectButton.centerXAnchor.constraint(equalTo: vGuide.centerXAnchor),
            selectButton.widthAnchor.constraint(lessThanOrEqualTo: vGuide.widthAnchor),
            selectButton.topAnchor.constraint(equalTo: hStack.bottomAnchor),
            selectButton.bottomAnchor.constraint(equalTo: vGuide.bottomAnchor),
        ])

        closeButton.addTarget(self, action: #selector(closePressed(sender:)), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectPressed(sender:)), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action handlers

    @objc private func closePressed(sender: UIButton) {
        onClose?()
    }

    @objc private func selectPressed(sender: UIButton) {
        selected.toggle()
    }
}
