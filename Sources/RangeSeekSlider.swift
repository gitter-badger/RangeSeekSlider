//
//  RangeSeekSlider.swift
//  RangeSeekSlider
//
//  Created by Keisuke Shoji on 2017/03/09.
//
//

import UIKit

@IBDesignable open class RangeSeekSlider: UIControl {

    // MARK: - initializers

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    public required override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public convenience init() {
        self.init(frame: .zero)
    }


    // MARK: - public stored properties

    public weak var delegate: RangeSeekSliderDelegate?

    /// The minimum possible value to select in the range
    @IBInspectable public var minValue: CGFloat = 0.0 {
        didSet {
            refresh()
        }
    }

    /// The maximum possible value to select in the range
    @IBInspectable public var maxValue: CGFloat = 100.0 {
        didSet {
            refresh()
        }
    }

    /// The preselected minumum value
    /// (note: This should be less than the selectedMaxValue)
    @IBInspectable public var selectedMinValue: CGFloat = 10.0 {
        didSet {
            if selectedMinValue < minValue {
                selectedMinValue = minValue
            }
        }
    }

    /// The preselected maximum value
    /// (note: This should be greater than the selectedMinValue)
    @IBInspectable public var selectedMaxValue: CGFloat = 90.0 {
        didSet {
            if selectedMaxValue > maxValue {
                selectedMaxValue = maxValue
            }
        }
    }

    /// The font of the minimum value text label. If not set, the default is system font size 12.0.
    public var minLabelFont: UIFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            minLabel.font = minLabelFont as CFTypeRef
            minLabel.fontSize = minLabelFont.pointSize
        }
    }

    /// The font of the maximum value text label. If not set, the default is system font size 12.0.
    public var maxLabelFont: UIFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            maxLabel.font = maxLabelFont as CFTypeRef
            maxLabel.fontSize = maxLabelFont.pointSize
        }
    }

    /// Each handle in the slider has a label above it showing the current selected value. By default, this is displayed as a decimal format.
    /// You can update this default here by updating properties of NumberFormatter. For example, you could supply a currency style, or a prefix or suffix.
    public let numberFormatter: NumberFormatter = {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// Hides the labels above the slider controls. true = labels will be hidden. false = labels will be shown. Default is false.
    @IBInspectable public var hideLabels: Bool = false

    /// The minimum distance the two selected slider values must be apart. Default is 0.

    @IBInspectable public var minDistance: CGFloat = 0.0 {
        didSet {
            if minDistance < 0.0 {
                minDistance = 0.0
            }
        }
    }

    /// The maximum distance the two selected slider values must be apart. Default is CGFloat.greatestFiniteMagnitude.

    @IBInspectable public var maxDistance: CGFloat = .greatestFiniteMagnitude {
        didSet {
            if maxDistance < 0.0 {
                maxDistance = .greatestFiniteMagnitude
            }
        }
    }

    /// The color of the minimum value text label. If not set, the default is the tintColor.
    @IBInspectable public var minLabelColor: UIColor? {
        didSet {
            minLabel.foregroundColor = minLabelColor?.cgColor
        }
    }

    /// The color of the maximum value text label. If not set, the default is the tintColor.
    @IBInspectable public var maxLabelColor: UIColor? {
        didSet {
            maxLabel.foregroundColor = maxLabelColor?.cgColor
        }
    }

    /// Handle slider with custom color, you can set custom color for your handle
    @IBInspectable public var handleColor: UIColor? {
        didSet {
            leftHandle.backgroundColor = handleColor?.cgColor
            rightHandle.backgroundColor = handleColor?.cgColor
        }
    }

    /// Handle slider with custom border color, you can set custom border color for your handle
    @IBInspectable public var handleBorderColor: UIColor? {
        didSet {
            leftHandle.borderColor = handleBorderColor?.cgColor
            rightHandle.borderColor = handleBorderColor?.cgColor
        }
    }

    /// Set slider line tint color between handles
    @IBInspectable public var colorBetweenHandles: UIColor? {
        didSet {
            sliderLineBetweenHandles.backgroundColor = colorBetweenHandles?.cgColor
        }
    }

    /// If true, the control will mimic a normal slider and have only one handle rather than a range.
    /// In this case, the selectedMinValue will be not functional anymore. Use selectedMaxValue instead to determine the value the user has selected.
    @IBInspectable public var disableRange: Bool = false {
        didSet {
            leftHandle.isHidden = disableRange
            minLabel.isHidden = disableRange
        }
    }

    /// If true the control will snap to point at each step between minValue and maxValue. Default is false.
    @IBInspectable public var enableStep: Bool = false

    /// The step value, this control the value of each step. If not set the default is 0.0.
    /// (note: this is ignored if <= 0.0)
    @IBInspectable public var step: CGFloat = 0.0

    /// Handle slider with custom image, you can set custom image for your handle
    @IBInspectable public var handleImage: UIImage? {
        didSet {
            let startFrame: CGRect = CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0)
            leftHandle.frame = startFrame
            leftHandle.contents = handleImage?.cgImage
            leftHandle.backgroundColor = UIColor.clear.cgColor

            rightHandle.frame = startFrame
            rightHandle.contents = handleImage?.cgImage
            rightHandle.backgroundColor = UIColor.clear.cgColor
        }
    }

    /// Handle diameter (default 16.0)
    @IBInspectable public var handleDiameter: CGFloat = 16.0 {
        didSet {
            leftHandle.cornerRadius = handleDiameter / 2.0
            rightHandle.cornerRadius = handleDiameter / 2.0
            leftHandle.frame = CGRect(x: 0.0, y: 0.0, width: handleDiameter, height: handleDiameter)
            rightHandle.frame = CGRect(x: 0.0, y: 0.0, width: handleDiameter, height: handleDiameter)
        }
    }

    /// Selected handle diameter multiplier (default 1.7)
    @IBInspectable public var selectedHandleDiameterMultiplier: CGFloat = 1.7

    /// Set the slider line height (default 1.0)
    @IBInspectable public var lineHeight: CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// Handle border width (default 0.0)
    @IBInspectable public var handleBorderWidth: CGFloat = 0.0 {
        didSet {
            leftHandle.borderWidth = handleBorderWidth
            rightHandle.borderWidth = handleBorderWidth
        }
    }

    /// Set padding between label and handle (default 8.0)
    @IBInspectable public var labelPadding: CGFloat = 8.0 {
        didSet {
            updateLabelPositions()
        }
    }

    /// The label displayed in accessibility mode for minimum value handler. If not set, the default is empty String.
    @IBInspectable public var minLabelAccessibilityLabel: String?

    /// The label displayed in accessibility mode for maximum value handler. If not set, the default is empty String.
    @IBInspectable public var maxLabelAccessibilityLabel: String?

    /// The brief description displayed in accessibility mode for minimum value handler. If not set, the default is empty String.
    @IBInspectable public var minLabelAccessibilityHint: String?

    /// The brief description displayed in accessibility mode for maximum value handler. If not set, the default is empty String.
    @IBInspectable public var maxLabelAccessibilityHint: String?


    // MARK: - private stored properties

    private let sliderLine: CALayer = CALayer()
    private let sliderLineBetweenHandles: CALayer = CALayer()

    private let leftHandle: CALayer = CALayer()
    private var leftHandleSelected: Bool = false
    private let rightHandle: CALayer = CALayer()
    private var rightHandleSelected: Bool = false

    fileprivate let minLabel: CATextLayer = CATextLayer()
    fileprivate let maxLabel: CATextLayer = CATextLayer()

    private var minLabelTextSize: CGSize = .zero
    private var maxLabelTextSize: CGSize = .zero

    // strong reference needed for UIAccessibilityContainer
    // see http://stackoverflow.com/questions/13462046/custom-uiview-not-showing-accessibility-on-voice-over
    private var accessibleElements: [UIAccessibilityElement] = []


    // MARK: - private computed properties

    private var leftHandleAccessibilityElement: UIAccessibilityElement {
        let element: RangeSeekSliderLeftElement = RangeSeekSliderLeftElement(accessibilityContainer: self)
        element.isAccessibilityElement = true
        element.accessibilityLabel = minLabelAccessibilityLabel
        element.accessibilityHint = minLabelAccessibilityHint
        element.accessibilityValue = minLabel.string as? String
        element.accessibilityFrame = convert(leftHandle.frame, to: nil)
        element.accessibilityTraits = UIAccessibilityTraitAdjustable
        return element
    }

    private var rightHandleAccessibilityElement: UIAccessibilityElement {
        let element: RangeSeekSliderRightElement = RangeSeekSliderRightElement(accessibilityContainer: self)
        element.isAccessibilityElement = true
        element.accessibilityLabel = maxLabelAccessibilityLabel
        element.accessibilityHint = maxLabelAccessibilityHint
        element.accessibilityValue = maxLabel.string as? String
        element.accessibilityFrame = convert(rightHandle.frame, to: nil)
        element.accessibilityTraits = UIAccessibilityTraitAdjustable
        return element
    }


    // MARK: - UIView

    open override func layoutSubviews() {
        super.layoutSubviews()

        // positioning for the slider line
        let barSidePadding: CGFloat = 16.0
        let currentFrame: CGRect = frame
        let yMiddle: CGFloat = currentFrame.height / 2.0
        let lineLeftSide: CGPoint = CGPoint(x: barSidePadding, y: yMiddle)
        let lineRightSide: CGPoint = CGPoint(x: (currentFrame.width - barSidePadding),
                                             y: yMiddle)
        sliderLine.frame = CGRect(x: lineLeftSide.x,
                                  y: lineLeftSide.y,
                                  width: lineRightSide.x - lineLeftSide.x,
                                  height: lineHeight)

        sliderLine.cornerRadius = lineHeight / 2.0

        updateLabelValues()
        updateHandlePositions()
        updateLabelPositions()
    }

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 65.0)
    }

    open override var tintColor: UIColor! {
        didSet {
            guard let color: CGColor = tintColor?.cgColor else { return }

            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))

            sliderLine.backgroundColor = color

            if handleColor == nil {
                leftHandle.backgroundColor = color
                rightHandle.backgroundColor = color
            }

            if minLabelColor == nil {
                minLabel.foregroundColor = color
            }

            if maxLabelColor == nil {
                maxLabel.foregroundColor = color
            }

            if colorBetweenHandles == nil {
                sliderLineBetweenHandles.backgroundColor = color
            }

            CATransaction.commit()
        }
    }


    // MARK: - UIControl

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation: CGPoint = touch.location(in: self)
        let insetExpansion: CGFloat = -30.0
        let isTouchingLeftHandle: Bool = leftHandle.frame.insetBy(dx: insetExpansion, dy: insetExpansion).contains(touchLocation)
        let isTouchingRightHandle: Bool = rightHandle.frame.insetBy(dx: insetExpansion, dy: insetExpansion).contains(touchLocation)

        guard isTouchingLeftHandle || isTouchingRightHandle else { return false }


        // the touch was inside one of the handles so we're definitely going to start movign one of them. But the handles might be quite close to each other, so now we need to find out which handle the touch was closest too, and activate that one.
        let distanceFromLeftHandle: CGFloat = touchLocation.distance(to: leftHandle.frame.center)
        let distanceFromRightHandle: CGFloat = touchLocation.distance(to: rightHandle.frame.center)

        if distanceFromLeftHandle < distanceFromRightHandle && !disableRange {
            leftHandleSelected = true
            animate(handle: leftHandle, selected: true)
        } else if selectedMaxValue == maxValue && leftHandle.frame.center.x == rightHandle.frame.center.x {
            leftHandleSelected = true
            animate(handle: leftHandle, selected: true)
        } else {
            rightHandleSelected = true
            animate(handle: rightHandle, selected: true)
        }

        delegate?.didStartTouches(in: self)

        return true
    }

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location: CGPoint = touch.location(in: self)

        // find out the percentage along the line we are in x coordinate terms (subtracting half the frames width to account for moving the middle of the handle, not the left hand side)
        let percentage: CGFloat = (location.x - sliderLine.frame.minX - handleDiameter / 2.0) / (sliderLine.frame.maxX - sliderLine.frame.minX)

        // multiply that percentage by self.maxValue to get the new selected minimum value
        let selectedValue: CGFloat = percentage * (maxValue - minValue) + minValue

        if leftHandleSelected {
            selectedMinValue = min(selectedValue, selectedMaxValue)
            refresh()
        } else if rightHandleSelected {
            // don't let the dots cross over, (unless range is disabled, in which case just dont let the dot fall off the end of the screen)
            if disableRange && selectedValue >= minValue {
                selectedMaxValue = selectedValue
            } else {
                selectedMaxValue = max(selectedValue, selectedMinValue)
            }
            refresh()
        } else {
            // no need to refresh the view because it is done as a side-effect of setting the property
        }

        return true
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if leftHandleSelected {
            leftHandleSelected = false
            animate(handle: leftHandle, selected: false)
        } else {
            rightHandleSelected = false
            animate(handle: rightHandle, selected: false)
        }
        delegate?.didEndTouches(in: self)
    }


    // MARK: - UIAccessibility

    open override func accessibilityElementCount() -> Int {
        return accessibleElements.count
    }

    open override func accessibilityElement(at index: Int) -> Any? {
        return accessibleElements[index]
    }

    open override func index(ofAccessibilityElement element: Any) -> Int {
        guard let element = element as? UIAccessibilityElement else { return 0 }
        return accessibleElements.index(of: element) ?? 0
    }


    // MARK: - private methods

    private func setup() {
        isAccessibilityElement = false
        accessibleElements = [leftHandleAccessibilityElement, rightHandleAccessibilityElement]

        // draw the slider line
        sliderLine.backgroundColor = tintColor.cgColor
        layer.addSublayer(sliderLine)

        // draw the track distline
        sliderLineBetweenHandles.backgroundColor = tintColor.cgColor
        layer.addSublayer(sliderLineBetweenHandles)

        // draw the minimum slider handle
        leftHandle.cornerRadius = handleDiameter / 2.0
        leftHandle.backgroundColor = tintColor.cgColor
        leftHandle.borderWidth = handleBorderWidth
        leftHandle.borderColor = handleBorderColor?.cgColor
        layer.addSublayer(leftHandle)

        // draw the maximum slider handle
        rightHandle.cornerRadius = handleDiameter / 2.0
        rightHandle.backgroundColor = tintColor.cgColor
        rightHandle.borderWidth = handleBorderWidth
        rightHandle.borderColor = handleBorderColor?.cgColor
        layer.addSublayer(rightHandle)

        let handleFrame: CGRect = CGRect(x: 0.0, y: 0.0, width: handleDiameter, height: handleDiameter)
        leftHandle.frame = handleFrame
        rightHandle.frame = handleFrame

        // draw the text labels
        let labelFontSize: CGFloat = 12.0
        let labelFrame: CGRect = CGRect(x: 0.0, y: 0.0, width: 75.0, height: 14.0)

        minLabelFont = UIFont.systemFont(ofSize: labelFontSize)
        minLabel.alignmentMode = kCAAlignmentCenter
        minLabel.frame = labelFrame
        minLabel.contentsScale = UIScreen.main.scale
        if let cgColor = minLabelColor?.cgColor {
            minLabel.foregroundColor = cgColor
        } else {
            minLabel.foregroundColor = tintColor.cgColor
        }
        layer.addSublayer(minLabel)

        maxLabelFont = UIFont.systemFont(ofSize: labelFontSize)
        maxLabel.alignmentMode = kCAAlignmentCenter
        maxLabel.frame = labelFrame
        maxLabel.contentsScale = UIScreen.main.scale
        if let cgColor = maxLabelColor?.cgColor {
            maxLabel.foregroundColor = cgColor
        } else {
            maxLabel.foregroundColor = tintColor.cgColor
        }
        layer.addSublayer(maxLabel)

        refresh()
    }

    private func percentageAlongLine(for value: CGFloat) -> CGFloat {
        // stops divide by zero errors where maxMinDif would be zero. If the min and max are the same the percentage has no point.
        guard minValue < maxValue else { return 0.0 }

        // get the difference between the maximum and minimum values (e.g if max was 100, and min was 50, difference is 50)
        let maxMinDif: CGFloat = maxValue - minValue

        // now subtract value from the minValue (e.g if value is 75, then 75-50 = 25)
        let valueSubtracted: CGFloat = value - minValue

        // now divide valueSubtracted by maxMinDif to get the percentage (e.g 25/50 = 0.5)
        return valueSubtracted / maxMinDif
    }

    private func xPositionAlongLine(for value: CGFloat) -> CGFloat {
        // first get the percentage along the line for the value
        let percentage: CGFloat = percentageAlongLine(for: value)

        // get the difference between the maximum and minimum coordinate position x values (e.g if max was x = 310, and min was x=10, difference is 300)
        let maxMinDif: CGFloat = sliderLine.frame.maxX - sliderLine.frame.minX

        // now multiply the percentage by the minMaxDif to see how far along the line the point should be, and add it onto the minimum x position.
        let offset: CGFloat = percentage * maxMinDif

        return sliderLine.frame.minX + offset
    }

    private func updateLabelValues() {
        if hideLabels {
            minLabel.string = nil
            maxLabel.string = nil
            return
        }

        minLabel.string = numberFormatter.string(from: selectedMinValue as NSNumber)
        maxLabel.string = numberFormatter.string(from: selectedMaxValue as NSNumber)

        if let nsstring = minLabel.string as? NSString {
            minLabelTextSize = nsstring.size(attributes: [NSFontAttributeName: minLabelFont])
        }

        if let nsstring = maxLabel.string as? NSString {
            maxLabelTextSize = nsstring.size(attributes: [NSFontAttributeName: maxLabelFont])
        }
    }

    private func updateAccessibilityElements() {
        accessibleElements = [leftHandleAccessibilityElement, rightHandleAccessibilityElement]
    }

    private func updateHandlePositions() {
        leftHandle.position = CGPoint(x: xPositionAlongLine(for: selectedMinValue),
                                      y: sliderLine.frame.midY)

        rightHandle.position = CGPoint(x: xPositionAlongLine(for: selectedMaxValue),
                                       y: sliderLine.frame.midY)

        // positioning for the dist slider line
        sliderLineBetweenHandles.frame = CGRect(x: leftHandle.position.x,
                                                y: sliderLine.frame.minY,
                                                width: rightHandle.position.x - leftHandle.position.x,
                                                height: lineHeight)
    }

    private func updateLabelPositions() {
        // the center points for the labels are X = the same x position as the relevant handle. Y = the y position of the handle minus half the height of the text label, minus some padding.
        let minSpacingBetweenLabels: CGFloat = 8.0

        let leftHandleCenter: CGPoint = leftHandle.frame.center
        let newMinLabelCenter: CGPoint = CGPoint(x: leftHandleCenter.x,
                                                 y: leftHandle.frame.minY - (minLabel.frame.height / 2.0) - labelPadding)

        let rightHandleCenter: CGPoint = rightHandle.frame.center
        let newMaxLabelCenter: CGPoint = CGPoint(x :rightHandleCenter.x,
                                                 y: rightHandle.frame.minY - (maxLabel.frame.height / 2.0) - labelPadding)

        minLabel.frame = CGRect(origin: .zero, size: minLabelTextSize)
        maxLabel.frame = CGRect(origin: .zero, size: maxLabelTextSize)

        let newLeftMostXInMaxLabel: CGFloat = newMaxLabelCenter.x - maxLabelTextSize.width / 2.0
        let newRightMostXInMinLabel: CGFloat = newMinLabelCenter.x + minLabelTextSize.width / 2.0
        let newSpacingBetweenTextLabels: CGFloat = newLeftMostXInMaxLabel - newRightMostXInMinLabel

        if disableRange || newSpacingBetweenTextLabels > minSpacingBetweenLabels {
            minLabel.position = newMinLabelCenter
            maxLabel.position = newMaxLabelCenter
        } else {
            let increaseAmount: CGFloat = minSpacingBetweenLabels - newSpacingBetweenTextLabels
            minLabel.position = CGPoint(x: newMinLabelCenter.x - increaseAmount / 2.0, y: newMinLabelCenter.y)
            maxLabel.position = CGPoint(x: newMaxLabelCenter.x + increaseAmount / 2.0, y: newMaxLabelCenter.y)

            // Update x if they are still in the original position
            if minLabel.position.x == maxLabel.position.x {
                minLabel.position = CGPoint(x: leftHandleCenter.x, y: minLabel.position.y)
                maxLabel.position = CGPoint(x: leftHandleCenter.x + minLabel.frame.width / 2.0 + minSpacingBetweenLabels + maxLabel.frame.width / 2.0,
                                            y: maxLabel.position.y)
            }
        }
    }

    fileprivate func refresh() {
        if enableStep && step > 0.0 {
            selectedMinValue = CGFloat(roundf(Float(selectedMinValue / step))) * step
            selectedMaxValue = CGFloat(roundf(Float(selectedMaxValue / step))) * step
        }

        let diff: CGFloat = selectedMaxValue - selectedMinValue

        if diff < minDistance {
            if leftHandleSelected {
                selectedMinValue = selectedMaxValue - minDistance
            } else {
                selectedMaxValue = selectedMinValue + minDistance
            }
        } else if diff > maxDistance {
            if leftHandleSelected {
                selectedMinValue = selectedMaxValue - maxDistance
            } else if rightHandleSelected {
                selectedMaxValue = selectedMinValue + maxDistance
            }
        }

        // ensure the minimum and maximum selected values are within range. Access the values directly so we don't cause this refresh method to be called again (otherwise changing the properties causes a refresh)
        if selectedMinValue < minValue {
            selectedMinValue = minValue
        }
        if selectedMaxValue > maxValue {
            selectedMaxValue = maxValue
        }

        // update the frames in a transaction so that the tracking doesn't continue until the frame has moved.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateHandlePositions()
        updateLabelPositions()
        CATransaction.commit()

        updateLabelValues()
        updateAccessibilityElements()

        // update the delegate
        if let delegate = delegate, leftHandleSelected || rightHandleSelected {
            delegate.rangeSeekSlider(self, didChange: selectedMinValue, maxValue: selectedMaxValue)
        }
    }

    private func animate(handle: CALayer, selected: Bool) {
        let transform: CATransform3D
        if selected {
            transform = CATransform3DMakeScale(selectedHandleDiameterMultiplier, selectedHandleDiameterMultiplier, 1.0)
        } else {
            transform = CATransform3DIdentity
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        handle.transform = transform

        // the label above the handle will need to move too if the handle changes size
        updateLabelPositions()

        CATransaction.commit()
    }
}


// MARK: - RangeSeekSliderLeftElement

private final class RangeSeekSliderLeftElement: UIAccessibilityElement {

    override func accessibilityIncrement() {
        guard let slider = accessibilityContainer as? RangeSeekSlider else { return }
        slider.selectedMinValue += slider.step
        accessibilityValue = slider.minLabel.string as? String
    }

    override func accessibilityDecrement() {
        guard let slider = accessibilityContainer as? RangeSeekSlider else { return }
        slider.selectedMinValue -= slider.step
        accessibilityValue = slider.minLabel.string as? String
    }
}


// MARK: - RangeSeekSliderRightElement

private final class RangeSeekSliderRightElement: UIAccessibilityElement {

    override func accessibilityIncrement() {
        guard let slider = accessibilityContainer as? RangeSeekSlider else { return }
        slider.selectedMaxValue += slider.step
        slider.refresh()
        accessibilityValue = slider.maxLabel.string as? String
    }

    override func accessibilityDecrement() {
        guard let slider = accessibilityContainer as? RangeSeekSlider else { return }
        slider.selectedMaxValue -= slider.step
        slider.refresh()
        accessibilityValue = slider.maxLabel.string as? String
    }
}


// MARK: - CGRect

private extension CGRect {

    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}


// MARK: - CGPoint

private extension CGPoint {

    func distance(to: CGPoint) -> CGFloat {
        let distX: CGFloat = to.x - x
        let distY: CGFloat = to.y - y
        return sqrt(distX * distX + distY * distY)
    }
}
