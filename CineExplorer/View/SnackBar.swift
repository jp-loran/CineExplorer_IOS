import UIKit

class SnackBar: UIView {

    private let messageLabel = UILabel()
    private let actionButton = UIButton()

    init(message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        super.init(frame: .zero)
        setupView()
        configure(message: message, actionTitle: actionTitle, action: action)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 5
        layer.masksToBounds = true

        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0

        actionButton.setTitleColor(.systemBlue, for: .normal)
        actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [messageLabel, actionButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    private func configure(message: String, actionTitle: String?, action: (() -> Void)?) {
        messageLabel.text = message
        if let actionTitle = actionTitle, let action = action {
            actionButton.setTitle(actionTitle, for: .normal)
            self.action = action
        } else {
            actionButton.isHidden = true
        }
    }

    private var action: (() -> Void)?

    @objc private func actionButtonTapped() {
        action?()
    }

    func show(in view: UIView, duration: Double = 2.0) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
}
