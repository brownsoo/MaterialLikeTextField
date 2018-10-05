//
//  MaterialLikeTextField.swift
//
//  Created by Brownsoo han on 2018. 4. 3..
//

import UIKit
import Foundation

public class MaterialLikeTextField: UITextField {
    
    struct DefaultValues {
        static let labelFontSize: CGFloat = 13
        static let leadingUnderlineTextFontSize: CGFloat = 13
        static let animationDuration: TimeInterval = 0.24
    }
    
    struct DefaultColorSet {
        let hexValue: Int
        
        init(_ hex: Int) {
            self.hexValue = hex
        }
        
        static let label = DefaultColorSet(0xff343a40)
        static let helper = DefaultColorSet(0x56343a40)
        static let placeholder = DefaultColorSet(0x56343a40)
        static let error = DefaultColorSet(0xfff95454)
        static let underline = DefaultColorSet(0x35000000)
        
        func uiColor() -> UIColor {
            let alpha = CGFloat((hexValue >> 24) & 0xff) / 255.0
            let red = CGFloat((hexValue >> 16) & 0xff) / 255.0
            let green = CGFloat((hexValue >> 8) & 0xff) / 255.0
            let blue = CGFloat(hexValue & 0xff) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    private struct PaddingConstraints {
        var leading: NSLayoutConstraint? = nil
        var trailing: NSLayoutConstraint? = nil
        var top: NSLayoutConstraint? = nil
        var bottom: NSLayoutConstraint? = nil
    }
    
    // MARK: Properties
    
    public var textPadding = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    public var changeLabelWithPlaceholder: Bool = true {
        didSet {
            layoutLabel(false)
        }
    }
    
    public var changeLabelWithPlaceholderWhenFocus = false
    /// inherited placeholder color
    public var placeHolderColor: UIColor = DefaultColorSet.placeholder.uiColor() {
        didSet {
            if let attrPlace = attributedPlaceholder {
                attributedPlaceholder = createAttributedString(attrPlace, withColor: placeHolderColor)
            }
        }
    }
    /// label color for normal state
    /// when field is focused, tint color is used
    public var labelColor = DefaultColorSet.label.uiColor() {
        didSet {
            updateLabelColor()
        }
    }
    
    public var labelTextSize: CGFloat = DefaultValues.labelFontSize {
        didSet {
            updateDefaultLabelFont()
        }
    }
    public var labelText: String?
    public var labelFont: UIFont = UIFont.systemFont(ofSize: DefaultValues.labelFontSize, weight: .regular) {
        didSet {
            self.label.font = labelFont
            self.updateLabelText()
        }
    }
    public var underlineHeight = CGFloat(1) {
        didSet {
            updateUnderlineFrame()
        }
    }
    /// underline height for focused
    public var underlineHeightFocused = CGFloat(2) {
        didSet {
            updateUnderlineFrame()
        }
    }
    /// underline color for normal state
    /// if focused, tintColor is used in the condition underlineColorActive is not set.
    public var underlineColor = DefaultColorSet.underline.uiColor() {
        didSet {
            updateUnderlineColor()
        }
    }
    /// if set, underline uses this color instead of tint color when focused
    public var underlineColorActive: UIColor? = nil {
        didSet {
            updateUnderlineColor()
        }
    }
    /// whether errorText is set or not
    public var hasError: Bool {
        return errorText != nil
    }
    /// whether helperText is set or not
    public var hasHelper: Bool {
        return helperText != nil
    }
    /// whether leading text is set or not.
    /// leading text : errorText, helperText
    public var hasLeadingTexts: Bool {
        return hasHelper || hasError
    }
    /// leading text with errorColor under the line
    public var errorText: String? = nil {
        didSet {
            layoutLeadingUnderlineLabel(superview != nil)
        }
    }
    /// leading text with leadingUnderlineLabelTextColor under the line
    public var helperText: String? = nil {
        didSet {
            layoutLeadingUnderlineLabel(superview != nil)
        }
    }
    
    public let leadingUnderlineFontDefault
        = UIFont.systemFont(ofSize: DefaultValues.leadingUnderlineTextFontSize, weight: .regular)
    public var leadingUnderlineLabelFont: UIFont! {
        didSet {
            self.leadingLabel.font = leadingUnderlineLabelFont
        }
    }
    public var leadingUnderlineLabelTextColor: UIColor = DefaultColorSet.helper.uiColor() {
        didSet {
            updateLeadingLabelTextColor()
        }
    }
    public var errorColor = DefaultColorSet.error.uiColor() {
        didSet {
            updateLeadingLabelTextColor()
        }
    }
    
    public var tintedClearImage: UIImage?
    public var nextTextField: MaterialTextField?
    
    // label --
    private lazy var label = UILabel()
    /// default top padding of label that is suggested in material design
    public var labelTopPadding: CGFloat = 16
    private var labelIsAnimating = false
    private var labelTopConstraint: NSLayoutConstraint?
    private var psAttributedString: NSAttributedString?
    
    private var _textRect: CGRect = CGRect()
    public private(set) var textRect: CGRect {
        set {
            _textRect = newValue
        }
        get {
            _textRect = self.textRect(forBounds: bounds)
            return _textRect
        }
    }
    private var underlineLayer: CALayer!
    
    public var shouldShowLabel: Bool {
        let isEmpty = text == nil || text!.isEmpty
        return !isEmpty
            || labelText != nil
            || (changeLabelWithPlaceholderWhenFocus && isFirstResponder)
    }
    
    /// padding for leading text under the underline.
    /// ex. helperText or errorText
    public var leadingLabelPadding = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0) {
        didSet {
            leadingLabelConstraints.leading?.constant = leadingLabelPadding.left
            leadingLabelConstraints.trailing?.constant = leadingLabelPadding.right
            leadingLabelConstraints.top?.constant = topOffsetForLeadingLabel(!hasLeadingTexts)
            leadingLabelConstraints.bottom?.constant = -leadingLabelPadding.bottom
        }
    }
    private lazy var leadingLabel = UILabel()
    private var leadingLabelConstraints = PaddingConstraints()
    private var leadingLabelZeroHeightConstraint: NSLayoutConstraint?
    private var leadingLabelIsAnimating = false
    
    // todo: trailing label
    
    private var defaultLabelFont: UIFont!
    private var placeholderText: String? = nil
    
    // MARK: override properties
    
    public override var font: UIFont? {
        didSet {
            self.updateDefaultLabelFont()
            self.updateLeadingLabelPositionY()
        }
    }
    public override var attributedText: NSAttributedString? {
        didSet {
            self.updateDefaultLabelFont()
        }
    }
    public override var placeholder: String? {
        didSet {
            self.placeholderText = placeholder
            self.psAttributedString = self.attributedPlaceholder
            self.updateLabelText()
        }
    }
    public override var attributedPlaceholder: NSAttributedString? {
        set {
            // change color of attributedPlaceholder
            let attr = self.createAttributedString(newValue, withColor: placeHolderColor)
            super.attributedPlaceholder = attr
            self.psAttributedString = attr // saved for revoking
            self.updateLabelText()
            self.updateDefaultLabelFont()
        }
        get {
            return super.attributedPlaceholder
        }
    }
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        if let lineHeight = self.font?.lineHeight {
            rect.size.height = lineHeight
        }
        rect.origin.y = adjustedYPositionForTextRect()
        self.textRect = rect
        return rect
    }
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.y = _textRect.midY - rect.size.height / 2
        return rect
    }
    public override var intrinsicContentSize: CGSize {
        var intrinsicSize = super.intrinsicContentSize
        if !hasLeadingTexts {
            intrinsicSize.height = underlineLayer.frame.maxY
        }
        return intrinsicSize
    }
    
    // it makes bounds area is responsive to touch
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !bounds.contains(point) {
            return false
        }
        return super.point(inside: point, with: event)
    }
    
    // MARK: Interface builder
    
    public override func prepareForInterfaceBuilder() {
        setupDefaults()
        setupTextField()
        setupUnderline()
        setupLeadingUnderlineLabel()
        changeLabelWithPlaceholder = false
    }
    
    // MARK: initializer
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeLook()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        makeLook()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        makeLook()
    }
    
    public convenience init() {
        self.init(frame: CGRect())
    }
    
    private func makeLook() {
        setupDefaults()
        setupTextField()
        setupUnderline()
        setupLabel()
        setupLeadingUnderlineLabel()
    }
    
    private func setupDefaults() {
        defaultLabelFont = getDefaultFontForLabel()
        leadingUnderlineLabelFont = leadingUnderlineFontDefault
    }
    
    private func setupTextField() {
        borderStyle = .none
        contentVerticalAlignment = .top
        clipsToBounds = false
    }
    
    private func setupUnderline() {
        //        print("✪ setupUnderline")
        underlineLayer = CALayer.init()
        layoutUnderlineLayer()
        layer.addSublayer(underlineLayer)
    }
    
    private func setupLeadingUnderlineLabel() {
        //        print("✪ setupLeadingUnderlineLabel")
        leadingLabel.translatesAutoresizingMaskIntoConstraints = false
        leadingLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        leadingLabel.setContentHuggingPriority(.required, for: .vertical)
        leadingLabel.font = leadingUnderlineLabelFont
        leadingLabel.textAlignment = .left
        leadingLabel.numberOfLines = 0
        leadingLabel.textColor = leadingUnderlineLabelTextColor
        addSubview(leadingLabel)
        setupLeadingUnderlineLabelConstraints()
        updateLeadingLabelText()
        layoutLeadingUnderlineLabel(false)
    }
    
    
    private func setupLabel() {
        //        print("✪ setupLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = labelFont
        label.textAlignment = textAlignment
        label.alpha = 0
        label.isHidden = true
        updateLabelText()
        updateLabelColor()
        addSubview(label)
        setupLabelConstraints()
    }
    
    // MARK: layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        //print(" layoutSubviews ---> ")
        layoutUnderlineLayer()
        // TODO: rightViewMode, clearButtonMode 등 기본 속성을 이용해 클리어 버튼 색상을 변경하는 것이 어떨지 확인하고 최적화하기
        tintClearButton()
        layoutLeadingUnderlineLabel(false)
        layoutLabel(true)
        
    }
    
    private func adjustedYPositionForTextRect() -> CGFloat {
        var top = ceil(textPadding.top)
        if changeLabelWithPlaceholder || labelText != nil {
            top += labelFont.lineHeight + labelTopPadding
        }
        return top
    }
    
    // MARK: for underline
    
    private func layoutUnderlineLayer() {
        updateUnderlineColor()
        updateUnderlineFrame()
    }
    
    private func updateUnderlineColor() {
        if hasError {
            self.underlineLayer.backgroundColor = errorColor.cgColor
        } else {
            if isFirstResponder {
                self.underlineLayer.backgroundColor =
                    underlineColorActive != nil ? underlineColorActive!.cgColor : tintColor.cgColor
            } else {
                self.underlineLayer.backgroundColor = underlineColor.cgColor
            }
        }
    }
    
    private func updateUnderlineFrame() {
        let lineHeight = isFirstResponder ? underlineHeightFocused : underlineHeight
        let y = textRect.maxY + textPadding.bottom - lineHeight
        underlineLayer.frame = CGRect(x: 0, y: y, width: bounds.width, height: lineHeight)
        if !leadingLabelIsAnimating {
            updateLeadingLabelPositionY()
        }
    }
    
    // MARK: for label
    
    /// Attributed 속성에서 기본 폰트를 구하거나 새로 생성한다.
    private func getDefaultFontForLabel() -> UIFont {
        var font: UIFont? = nil
        if let attributedPlaceholder = self.attributedPlaceholder, attributedPlaceholder.length > 0 {
            font = attributedPlaceholder.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont
        } else if let attr = self.psAttributedString, attr.length > 0 {
            font = attr.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont
        } else if let attributedText = self.attributedText, attributedText.length > 0 {
            font = attributedText.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont
        } else {
            font = self.font
        }
        if let font = font {
            return UIFont(name: font.fontName, size: labelTextSize)!
        }
        return UIFont.systemFont(ofSize: labelTextSize, weight: .regular)
    }
    
    private func createAttributedString(_ attributedString: NSAttributedString?, withColor color: UIColor) -> NSAttributedString {
        let attributes: NSMutableDictionary
        if let attributedString = attributedString, attributedString.length > 0 {
            attributes = NSMutableDictionary(dictionary: attributedString.attributes(at: 0, effectiveRange: nil))
        } else {
            attributes = NSMutableDictionary()
        }
        attributes[NSAttributedString.Key.foregroundColor] = color
        
        return NSAttributedString(string: attributedString?.string ?? "", attributes: attributes as? [NSAttributedString.Key: Any])
    }
    
    private func updateLabelText() {
        if changeLabelWithPlaceholder && placeholderText != nil && isFirstResponder {
            label.text = placeholderText!
        } else {
            label.text = labelText ?? psAttributedString?.string
        }
    }
    
    // 라벨도 기본 폰트와 같은 폰트를 사용하면 같이 수정해준다.
    private func updateDefaultLabelFont() {
        let isUsingDefaultFont = labelFont.isEqual(defaultLabelFont)
        defaultLabelFont = getDefaultFontForLabel()
        if isUsingDefaultFont {
            labelFont = defaultLabelFont
            label.font = labelFont
        }
    }
    
    private func updateLabelColor() {
        if isFirstResponder {
            label.textColor = tintColor
        } else {
            label.textColor = labelColor
        }
    }
    
    private func setupLabelConstraints() {
        if let parent = label.superview {
            label.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor).isActive = true
            let offsetFromTop = textRect.minY / 2 + labelTopPadding
            labelTopConstraint = label.topAnchor.constraint(equalTo: parent.topAnchor, constant: offsetFromTop)
            labelTopConstraint?.isActive = true
        }
    }
    
    private func layoutLabel(_ animated: Bool) {
        if shouldShowLabel {
            //print("라벨표시 animated:\(animated)")
            updateLabelText()
            updateLabelColor()
            showLabel(animated)
        } else {
            //print("라벨표시 안해도 되네 animated:\(animated)")
            hideLabel(animated)
        }
    }
    
    private func showLabel(_ animated: Bool) {
        if changeLabelWithPlaceholderWhenFocus {
            // psAttributedString is not set to nil
            if isFirstResponder {
                //print("슈퍼 플래이스홀더 삭제 ")
                super.placeholder = nil
            } else if (super.placeholder != placeholderText) {
                //                print("슈퍼 플래이스홀더 복구 \(placeholderText ?? "-")")
                super.placeholder = placeholderText
                self.attributedPlaceholder = psAttributedString
            }
        }
        if !label.isHidden {
            return
        }
        if animated && !labelIsAnimating {
            labelIsAnimating = true
            //            print("start showing ----------------------> ")
            //superview?.layoutIfNeeded()
            labelTopConstraint?.constant = labelTopPadding
            UIView.animate(withDuration: DefaultValues.animationDuration,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: { [weak self] in
                            self?.label.alpha = 1
                            self?.label.isHidden = false
                            // self.superview?.layoutIfNeeded()
            }) { [weak self] finished in
                self?.labelIsAnimating = false
                // if state has changed during animation
                if self != nil && !self!.shouldShowLabel {
                    self?.hideLabel(false)
                }
            }
        } else if !animated {
            //            print("immediately shown")
            labelIsAnimating = false
            label.isHidden = false
            label.alpha = 1
            labelTopConstraint?.constant = labelTopPadding
        }
    }
    
    private func hideLabel(_ animated: Bool) {
        if changeLabelWithPlaceholderWhenFocus
            && super.placeholder != placeholderText {
            super.placeholder = placeholderText
            attributedPlaceholder = psAttributedString
        }
        
        if label.isHidden {
            return
        }
        let finalOffsetFromTop = textRect.minY / 2 + labelTopPadding
        if animated && !labelIsAnimating {
            labelIsAnimating = true
            //            print("start hiding ----------------------> ")
            labelTopConstraint?.constant = finalOffsetFromTop
            UIView.animate(
                withDuration: DefaultValues.animationDuration * 0.3,
                delay: 0,
                options: .curveEaseOut,
                animations: { [weak self] in
                    self?.label.alpha = 0
                    //self.superview?.layoutIfNeeded()
                },
                completion: { [weak self] finished in
                    self?.labelIsAnimating = false
                    self?.label.isHidden = true
                    // if state has changed since animation started
                    if self != nil && self!.shouldShowLabel {
                        self?.showLabel(false)
                    }
            })
        } else if !animated {
            //            print("immediately hidden")
            labelIsAnimating = false
            label.isHidden = true
            label.alpha = 0
            labelTopConstraint?.constant = finalOffsetFromTop
        }
    }
    
    // MARK: for assistant text
    
    private func setupLeadingUnderlineLabelConstraints() {
        leadingLabel.translatesAutoresizingMaskIntoConstraints = false
        // top
        let topPadding = topOffsetForLeadingLabel(!hasLeadingTexts)
        leadingLabelConstraints.top = leadingLabel.topAnchor.constraint(
            equalTo: self.topAnchor, constant: topPadding)
        leadingLabelConstraints.top?.isActive = true
        // bottom
        leadingLabelConstraints.bottom = leadingLabel.bottomAnchor.constraint(
            equalTo: self.bottomAnchor, constant: -leadingLabelPadding.bottom)
        leadingLabelConstraints.bottom?.priority = .init(900.0)
        leadingLabelConstraints.bottom?.isActive = true
        // leading
        leadingLabelConstraints.leading = leadingLabel.leadingAnchor.constraint(
            equalTo: self.leadingAnchor, constant: leadingLabelPadding.left)
        leadingLabelConstraints.leading?.isActive = true
        // trailing
        leadingLabelConstraints.trailing = leadingLabel.trailingAnchor.constraint(
            lessThanOrEqualTo: self.trailingAnchor, constant: -leadingLabelPadding.right)
        leadingLabelConstraints.trailing?.isActive = true
        // zero height
        leadingLabelZeroHeightConstraint = leadingLabel.heightAnchor.constraint(equalToConstant: 0)
        leadingLabelZeroHeightConstraint?.isActive = !hasLeadingTexts
    }
    
    public func setErrorText(_ errorText: String?, animated: Bool = false) {
        self.errorText = errorText
        layoutLeadingUnderlineLabel(animated)
    }
    
    public func setHelperText(_ helperText: String?, animated: Bool = false) {
        self.helperText = helperText
        layoutLeadingUnderlineLabel(animated)
    }
    
    private func layoutLeadingUnderlineLabel(_ animated: Bool) {
        //        print("hasError: \(hasError),  hasHelper: \(hasHelper)")
        if hasLeadingTexts {
            //            print("리딩 라벨 표시")
            showLeadingUnderlineLabel(animated)
        } else {
            //            print("리딩 라벨 삭제")
            hideLeadingUnderlineLabel(animated)
        }
    }
    
    private func topOffsetForLeadingLabel(_ hidden: Bool) -> CGFloat {
        if hidden {
            return underlineLayer.frame.maxY
        }
        return underlineLayer.frame.maxY + leadingLabelPadding.top
    }
    
    private func updateLeadingLabelPositionY() {
        leadingLabelConstraints.top?.constant = topOffsetForLeadingLabel(!hasLeadingTexts)
    }
    
    private func updateLeadingLabelText() {
        leadingLabel.text = hasError ? errorText : helperText
        leadingLabel.sizeToFit()
    }
    
    private func updateLeadingLabelTextColor() {
        leadingLabel.textColor = hasError ? errorColor : leadingUnderlineLabelTextColor
    }
    
    private func showLeadingUnderlineLabel(_ animated: Bool) {
        updateLeadingLabelText()
        updateLeadingLabelTextColor()
        if animated && !leadingLabelIsAnimating {
            //superview?.layoutIfNeeded()
            leadingLabelIsAnimating = true
            leadingLabelZeroHeightConstraint?.isActive = false
            leadingLabelConstraints.top?.constant = topOffsetForLeadingLabel(false)
            //            print("------leadingLabel")
            UIView.animate(
                withDuration: DefaultValues.animationDuration,
                delay: 0,
                options: .curveEaseOut,
                animations: { [weak self] in
                    self?.leadingLabel.alpha = 1
                    self?.leadingLabel.isHidden = false
                },
                completion: { [weak self] _ in
                    self?.leadingLabelIsAnimating = false
                    // if 'hasError' is changed during animation
                    if self != nil && !self!.hasLeadingTexts {
                        self?.hideLeadingUnderlineLabel(false)
                    }
            })
        } else if (!animated) {
            leadingLabelIsAnimating = false
            leadingLabel.isHidden = false
            leadingLabel.alpha = 1
            leadingLabelZeroHeightConstraint?.isActive = false
            leadingLabelConstraints.top?.constant = topOffsetForLeadingLabel(false)
        }
    }
    
    private func hideLeadingUnderlineLabel(_ animated: Bool) {
        if animated && !leadingLabelIsAnimating {
            leadingLabelIsAnimating = true
            UIView.animate(
                withDuration: DefaultValues.animationDuration,
                delay: 0,
                options: .curveLinear,
                animations: {
                    self.leadingLabel.alpha = 0
            },
                completion: { [weak self] finished in
                    self?.leadingLabel.isHidden = true
                    self?.leadingLabelConstraints.top?.constant = self?.topOffsetForLeadingLabel(true) ?? 0
                    self?.leadingLabelZeroHeightConstraint?.isActive = true
                    
                    self?.leadingLabelIsAnimating = false
                    self?.updateLeadingLabelText()
                    // if 'hasError' has changed duration animation
                    if self != nil && self!.hasLeadingTexts {
                        self?.showLeadingUnderlineLabel(false)
                    }
            })
        } else if (!animated) {
            leadingLabel.alpha = 0
            leadingLabel.isHidden = true
            leadingLabelConstraints.top?.constant = topOffsetForLeadingLabel(true)
            leadingLabelZeroHeightConstraint?.isActive = true
        }
    }
}

extension MaterialLikeTextField {
    
    var clearButton: UIButton? {
        for view in subviews {
            if view.isKind(of: UIButton.self) {
                return (view as! UIButton)
            }
        }
        return nil
    }
    
    func tintClearButton() {
        if let button = self.clearButton,
            let clearImage = button.image(for: .highlighted) {
            if tintedClearImage == nil {
                tintedClearImage = clearImage.tintedImage(color: tintColor)
            }
            if let image = tintedClearImage {
                button.setImage(image, for: .highlighted)
            }
        }
    }
    
}

extension UIImage {
    func tintedImage(color tintColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        tintColor.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        let tinted = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tinted
    }
}



