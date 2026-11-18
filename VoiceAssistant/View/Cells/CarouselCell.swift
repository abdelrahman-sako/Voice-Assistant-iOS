import UIKit

private enum CarouselPalette {
    static var text: UIColor {
        if #available(iOS 13.0, *) { return .label }
        return .black
    }

    static var secondaryText: UIColor {
        if #available(iOS 13.0, *) { return .secondaryLabel }
        return .darkGray
    }

    static var cardBackground: UIColor {
        if #available(iOS 13.0, *) { return .secondarySystemBackground }
        return UIColor(white: 0.97, alpha: 1)
    }

    static var placeholder: UIColor {
        if #available(iOS 13.0, *) { return .tertiarySystemFill }
        return UIColor(white: 0.9, alpha: 1)
    }

    static var separator: UIColor {
        if #available(iOS 13.0, *) { return .separator }
        return UIColor(white: 0.88, alpha: 1)
    }

    static var buttonTint: UIColor {
        let configured = AssistantConfig.botViewheme.linkColor
        return configured == .clear ? .systemBlue : configured
    }
}

final class CarouselCell: UITableViewCell {
    static let reuseIdentifier = "CarouselCell"

    private static let horizontalInset: CGFloat = 20
    private static let verticalInset: CGFloat = 8
    private static let scrollTopPadding: CGFloat = 4
    private static let scrollBottomPadding: CGFloat = 8
    private static let cardSpacing: CGFloat = 10

    private let contentStack = UIStackView()
    private let messageContainer = UIView()
    private let messageLabel = UILabel()
    private let cardsScrollView = UIScrollView()
    private let cardsStack = UIStackView()
    private var cardsHeightConstraint: NSLayoutConstraint!
    private var shouldPositionCardsAtRight = false

    var onButtonSelected: ((DialogCardButton) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onButtonSelected = nil
        shouldPositionCardsAtRight = false
        messageLabel.attributedText = nil
        messageLabel.text = nil
        cardsStack.arrangedSubviews.forEach {
            cardsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard shouldPositionCardsAtRight else { return }
        cardsScrollView.layoutIfNeeded()
        guard cardsScrollView.bounds.width > 0, cardsScrollView.contentSize.width > 0 else { return }
        let rightmostOffset = max(0, cardsScrollView.contentSize.width - cardsScrollView.bounds.width)
        cardsScrollView.setContentOffset(CGPoint(x: rightmostOffset, y: 0), animated: false)
        shouldPositionCardsAtRight = false
    }

    private func configureView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStack)

        messageLabel.numberOfLines = 0
        messageLabel.textColor = Self.messageColor()
        messageLabel.font = Self.messageFont()
        messageLabel.textAlignment = .natural
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageContainer.addSubview(messageLabel)

        cardsScrollView.showsHorizontalScrollIndicator = false
        cardsScrollView.showsVerticalScrollIndicator = false
        cardsScrollView.clipsToBounds = false
        cardsScrollView.translatesAutoresizingMaskIntoConstraints = false

        cardsStack.axis = .horizontal
        cardsStack.alignment = .fill
        cardsStack.distribution = .fill
        cardsStack.spacing = Self.cardSpacing
        cardsStack.translatesAutoresizingMaskIntoConstraints = false
        cardsScrollView.addSubview(cardsStack)

        contentStack.addArrangedSubview(messageContainer)
        contentStack.addArrangedSubview(cardsScrollView)

        cardsHeightConstraint = cardsScrollView.heightAnchor.constraint(equalToConstant: 12)
        cardsHeightConstraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.verticalInset),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Self.verticalInset),

            messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: Self.horizontalInset),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -Self.horizontalInset),
            messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor),

            cardsHeightConstraint,

            cardsStack.leadingAnchor.constraint(equalTo: cardsScrollView.contentLayoutGuide.leadingAnchor, constant: Self.horizontalInset),
            cardsStack.trailingAnchor.constraint(equalTo: cardsScrollView.contentLayoutGuide.trailingAnchor, constant: -Self.horizontalInset),
            cardsStack.topAnchor.constraint(equalTo: cardsScrollView.contentLayoutGuide.topAnchor, constant: Self.scrollTopPadding),
            cardsStack.bottomAnchor.constraint(equalTo: cardsScrollView.contentLayoutGuide.bottomAnchor, constant: -Self.scrollBottomPadding),
            cardsStack.heightAnchor.constraint(equalTo: cardsScrollView.frameLayoutGuide.heightAnchor, constant: -(Self.scrollTopPadding + Self.scrollBottomPadding))
        ])
    }

    func setData(dialog: ConversationDialog, availableWidth: CGFloat) {
        let effectiveWidth = Self.resolvedWidth(availableWidth)
        let hasMessage = dialog.hasMessage
        messageContainer.isHidden = !hasMessage
        if let message = dialog.message, !message.isEmpty {
            Self.applyMessage(message, to: messageLabel)
        } else {
            messageLabel.attributedText = nil
            messageLabel.text = nil
        }

        cardsStack.arrangedSubviews.forEach {
            cardsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let cards = dialog.cards?.items ?? []
        let displayedCards = LbLanguage.isArabic ? Array(cards.reversed()) : cards
        let cardWidths = displayedCards.map { Self.cardWidth(for: $0, availableWidth: effectiveWidth) }
        let cardsHeight = zip(displayedCards, cardWidths)
            .map { Self.measureCardHeight(card: $0.0, width: $0.1) }
            .max() ?? 0

        cardsHeightConstraint.constant = cardsHeight + Self.scrollTopPadding + Self.scrollBottomPadding
        shouldPositionCardsAtRight = LbLanguage.isArabic
        cardsScrollView.setContentOffset(.zero, animated: false)

        for (index, card) in displayedCards.enumerated() {
            let cardView = CarouselCardView(
                card: card,
                width: cardWidths[index],
                onButtonSelected: { [weak self] button in
                    self?.onButtonSelected?(button)
                }
            )
            cardsStack.addArrangedSubview(cardView)
        }

        if shouldPositionCardsAtRight {
            setNeedsLayout()
        }
    }

    static func rowHeight(for dialog: ConversationDialog, availableWidth: CGFloat) -> CGFloat {
        let effectiveWidth = resolvedWidth(availableWidth)
        let cards = dialog.cards?.items ?? []
        let maxCardHeight = cards.map { card in
            measureCardHeight(card: card, width: cardWidth(for: card, availableWidth: effectiveWidth))
        }.max() ?? 0

        var messageHeight: CGFloat = 0
        if let message = dialog.message, !message.isEmpty {
            let probeLabel = UILabel()
            probeLabel.numberOfLines = 0
            probeLabel.font = messageFont()
            probeLabel.textColor = messageColor()
            applyMessage(message, to: probeLabel)
            let labelWidth = max(1, effectiveWidth - horizontalInset * 2)
            messageHeight = ceil(probeLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude)).height)
        }

        let messageSectionHeight = messageHeight > 0 ? messageHeight + 8 : 0
        return verticalInset * 2 + messageSectionHeight + maxCardHeight + scrollTopPadding + scrollBottomPadding
    }

    private static func resolvedWidth(_ availableWidth: CGFloat) -> CGFloat {
        availableWidth > 0 ? availableWidth : UIScreen.main.bounds.width
    }

    private static func cardWidth(for card: DialogCard, availableWidth: CGFloat) -> CGFloat {
        let baseWidth = card.type.imageSize.width + ipadFactor * 150
        let maxWidth = max(180, availableWidth - horizontalInset * 2)
        return min(baseWidth, maxWidth)
    }

    private static func measureCardHeight(card: DialogCard, width: CGFloat) -> CGFloat {
        let cardView = CarouselCardView(card: card, width: width, onButtonSelected: { _ in })
        cardView.layoutIfNeeded()
        let size = cardView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return ceil(size.height)
    }

    private static func messageFont() -> UIFont {
        AssistantConfig.botViewheme.defualtTextStyle.font ?? UIFont.systemFont(ofSize: 16)
    }

    private static func messageColor() -> UIColor {
        AssistantConfig.botViewheme.defualtTextStyle.color
    }

    private static func applyMessage(_ message: String, to label: UILabel) {
        let regularFont = messageFont()
        let boldFont = UIFont.boldSystemFont(ofSize: regularFont.pointSize)
        let color = messageColor()
        if message.containsAnchorTags || message.containsHTML {
            let attributed = message.htmlAttributedString(
                regularFont: regularFont,
                boldFont: boldFont,
                color: color,
                linkColor: AssistantConfig.botViewheme.linkColor
            )
            if attributed.length > 0 {
                label.attributedText = attributed
                return
            }
        }
        label.font = regularFont
        label.textColor = color
        label.text = message
    }
}

private final class CarouselCardView: UIView, UIGestureRecognizerDelegate {
    private let backgroundContainer = UIView()
    private let contentStack = UIStackView()
    private let imageView = UIImageView()
    private let imageIndicator: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        }
        return UIActivityIndicatorView(style: .gray)
    }()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let spacerView = UIView()
    private let buttonsStack = UIStackView()
    private let card: DialogCard
    private let onButtonSelected: (DialogCardButton) -> Void
    private var currentImageURLString: String?

    init(card: DialogCard, width: CGFloat, onButtonSelected: @escaping (DialogCardButton) -> Void) {
        self.card = card
        self.onButtonSelected = onButtonSelected
        super.init(frame: .zero)

        let cornerRadius = 10 + 30 * ipadFactor
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1.5
        layer.shadowOpacity = 0.15
        layer.masksToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true

        backgroundContainer.backgroundColor = CarouselPalette.cardBackground
        backgroundContainer.layer.cornerRadius = cornerRadius
        backgroundContainer.clipsToBounds = true
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundContainer)

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainer.addSubview(contentStack)

        let trimmedImageURL = card.imageUrl?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasImage = card.image != nil || !(trimmedImageURL?.isEmpty ?? true)
        let imageHeight = hasImage ? (card.type.imageSize.hight + ipadFactor * 70) : 0

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = CarouselPalette.placeholder
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.layer.cornerRadius = cornerRadius
        imageView.isHidden = !hasImage
        imageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true

        imageIndicator.hidesWhenStopped = true
        imageIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(imageIndicator)
        NSLayoutConstraint.activate([
            imageIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])

        contentStack.addArrangedSubview(imageView)

        let trimmedTitle = card.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSubtitle = card.subtitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasTitle = !trimmedTitle.isEmpty
        let hasSubtitle = !trimmedSubtitle.isEmpty

        if hasTitle || hasSubtitle {
            let detailsStack = UIStackView()
            detailsStack.axis = .vertical
            detailsStack.spacing = 4
            detailsStack.isLayoutMarginsRelativeArrangement = true
            detailsStack.layoutMargins = UIEdgeInsets(top: 6, left: 8, bottom: 8, right: 8)

            if hasTitle {
                titleLabel.text = trimmedTitle
                titleLabel.font = .boldSystemFont(ofSize: 16 + ipadFactor)
                titleLabel.textColor = CarouselPalette.text
                titleLabel.textAlignment = .center
                titleLabel.numberOfLines = 3
                titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
                detailsStack.addArrangedSubview(titleLabel)
            }

            if hasSubtitle {
                let subtitleFont = UIFont.systemFont(ofSize: 13 + ipadFactor)
                if trimmedSubtitle.containsAnchorTags || trimmedSubtitle.containsHTML {
                    subtitleLabel.attributedText = trimmedSubtitle.htmlAttributedString(
                        regularFont: subtitleFont,
                        boldFont: .boldSystemFont(ofSize: subtitleFont.pointSize),
                        color: CarouselPalette.secondaryText,
                        linkColor: CarouselPalette.buttonTint
                    )
                } else {
                    subtitleLabel.font = subtitleFont
                    subtitleLabel.textColor = CarouselPalette.secondaryText
                    subtitleLabel.text = trimmedSubtitle
                }
                subtitleLabel.textAlignment = .center
                subtitleLabel.numberOfLines = 0
                subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
                detailsStack.addArrangedSubview(subtitleLabel)
            }

            contentStack.addArrangedSubview(detailsStack)
        }

        spacerView.backgroundColor = .clear
        spacerView.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        spacerView.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
        contentStack.addArrangedSubview(spacerView)

        let shouldHideSingleDuplicateButton = card.buttons.count == 1 &&
            card.buttons[0].title.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedTitle

        buttonsStack.axis = .vertical
        buttonsStack.spacing = 0

        if !card.buttons.isEmpty && !shouldHideSingleDuplicateButton {
            let buttonHeight: CGFloat = 35 + ipadFactor * 20
            for (index, cardButton) in card.buttons.enumerated() {
                let rowContainer = UIView()
                rowContainer.backgroundColor = .clear

                let separator = UIView()
                separator.backgroundColor = CarouselPalette.separator
                separator.translatesAutoresizingMaskIntoConstraints = false
                rowContainer.addSubview(separator)

                let button = UIButton(type: .system)
                button.tag = index
                button.setTitle(cardButton.title, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
                button.titleLabel?.lineBreakMode = .byTruncatingTail
                button.setTitleColor(CarouselPalette.buttonTint, for: .normal)
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                rowContainer.addSubview(button)

                NSLayoutConstraint.activate([
                    rowContainer.heightAnchor.constraint(equalToConstant: buttonHeight),
                    separator.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor),
                    separator.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor),
                    separator.topAnchor.constraint(equalTo: rowContainer.topAnchor),
                    separator.heightAnchor.constraint(equalToConstant: 1),

                    button.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor),
                    button.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor),
                    button.topAnchor.constraint(equalTo: separator.bottomAnchor),
                    button.bottomAnchor.constraint(equalTo: rowContainer.bottomAnchor)
                ])

                buttonsStack.addArrangedSubview(rowContainer)
            }
            contentStack.addArrangedSubview(buttonsStack)
        }

        if card.buttons.count == 1 {
            let cardTap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
            cardTap.cancelsTouchesInView = false
            cardTap.delegate = self
            backgroundContainer.addGestureRecognizer(cardTap)
        }

        NSLayoutConstraint.activate([
            backgroundContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundContainer.topAnchor.constraint(equalTo: topAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: backgroundContainer.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor)
        ])

        if let image = card.image {
            imageView.image = image
            imageIndicator.stopAnimating()
        } else if let urlString = trimmedImageURL, !urlString.isEmpty, let url = URL(string: urlString) {
            currentImageURLString = urlString
            imageIndicator.startAnimating()
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self,
                      let data = data,
                      let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        self?.imageIndicator.stopAnimating()
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.imageIndicator.stopAnimating()
                    card.image = image
                    if self.currentImageURLString == urlString {
                        self.imageView.image = image
                    }
                }
            }.resume()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard card.buttons.indices.contains(sender.tag) else { return }
        onButtonSelected(card.buttons[sender.tag])
    }

    @objc private func cardTapped() {
        guard card.buttons.count == 1 else { return }
        onButtonSelected(card.buttons[0])
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UIControl)
    }
}
