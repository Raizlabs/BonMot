//
//  StyleableTextContainer.swift
//
//  Created by Brian King on 8/11/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

/// A StyleableTextContainer is a protocol that a text container can conform to to represent text that can be styled. This is 
/// usually a UIView subclass or an "Item" view model.
public protocol StyleableTextContainer: AnyObject {

    /// The style to use for this container. The containers is updated when this property is set if the container conforms to AdaptableTextContainer
    var bonMotStyle: StyleAttributeTransformation? { get set }

}

internal enum StyleableSupport {
    static var containerHandle: UInt8 = 0

    static func getStyle(object theObject: NSObject) -> StyleAttributeTransformation? {
        let adaptiveFunctionContainer = objc_getAssociatedObject(theObject, &containerHandle) as? StyleAttributeTransformationHolder
        return adaptiveFunctionContainer?.style
    }

    static func setStyle(object theObject: NSObject, bonMotStyle: StyleAttributeTransformation?) {
        var adaptiveFunction: StyleAttributeTransformationHolder? = nil
        if let bonMotStyle = bonMotStyle {
            adaptiveFunction = StyleAttributeTransformationHolder(style: bonMotStyle)
        }
        objc_setAssociatedObject(
            theObject, &containerHandle,
            adaptiveFunction,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        if let traitEnvironment = theObject as? UITraitEnvironment, let container = theObject as? AdaptableTextContainer {
            container.updateText(forTraitCollection: traitEnvironment.traitCollection)
        }
    }
}

@objc(BONStyleAttributeTransformationHolder)
class StyleAttributeTransformationHolder: NSObject {

    let style: StyleAttributeTransformation
    init(style: StyleAttributeTransformation) {
        self.style = style
    }
}

extension StyleableTextContainer {

    internal final func styledAttributedString(forText text: String?, traitCollection: UITraitCollection?) -> NSAttributedString? {
        if let text = text {
            var string = (bonMotStyle ?? BonMot()).attributedString(from: text)
            if let traitCollection = traitCollection {
                string = string.adapt(to: traitCollection)
            }
            return string
        }
        else {
            return nil
        }
    }
    
}

extension UILabel: StyleableTextContainer {

    public final var bonMotStyle: StyleAttributeTransformation? {
        get { return StyleableSupport.getStyle(object: self) }
        set { StyleableSupport.setStyle(object: self, bonMotStyle: newValue) }
    }

    @objc(bon_styledText)
    public var styledText: String? {
        set { attributedText = styledAttributedString(forText: newValue, traitCollection: traitCollection) }
        get { return attributedText?.string }
    }
}

extension UITextField: StyleableTextContainer {

    public final var bonMotStyle: StyleAttributeTransformation? {
        get { return StyleableSupport.getStyle(object: self) }
        set { StyleableSupport.setStyle(object: self, bonMotStyle: newValue) }
    }

    @objc(bon_styledText)
    public var styledText: String? {
        set { attributedText = styledAttributedString(forText: newValue, traitCollection: traitCollection) }
        get { return attributedText?.string }
    }
}

extension UITextView: StyleableTextContainer {

    public final var bonMotStyle: StyleAttributeTransformation? {
        get { return StyleableSupport.getStyle(object: self) }
        set { StyleableSupport.setStyle(object: self, bonMotStyle: newValue) }
    }

    @objc(bon_styledText)
    public var styledText: String? {
        set { attributedText = styledAttributedString(forText: newValue, traitCollection: traitCollection) }
        get { return attributedText?.string }
    }
}

extension UIButton: StyleableTextContainer {

    public final var bonMotStyle: StyleAttributeTransformation? {
        get { return StyleableSupport.getStyle(object: self) }
        set { StyleableSupport.setStyle(object: self, bonMotStyle: newValue) }
    }

    #if swift(>=3.0)
    @objc(bon_setStyledText:for:)
    public func setStyledText(_ text: String, forState state: UIControlState) {
        setAttributedTitle(styledAttributedString(forText: text, traitCollection: traitCollection), for: state)
    }
    #else
    @objc(bon_setStyledText:forState:)
    public func setStyledText(_ text: String, forState state: UIControlState) {
        setAttributedTitle(styledAttributedString(forText: text, traitCollection: traitCollection), for: state)
    }
    #endif

}

extension UISegmentedControl: StyleableTextContainer {

    public final var bonMotStyle: StyleAttributeTransformation? {
        get { return StyleableSupport.getStyle(object: self) }
        set { StyleableSupport.setStyle(object: self, bonMotStyle: newValue) }
    }

}

extension UIBarItem: StyleableTextContainer {

    public final var bonMotStyle: StyleAttributeTransformation? {
        get { return StyleableSupport.getStyle(object: self) }
        set { StyleableSupport.setStyle(object: self, bonMotStyle: newValue) }
    }

}

extension UINavigationBar: StyleableTextContainer {

    public final var bonMotStyle: StyleAttributeTransformation? {
        get { return StyleableSupport.getStyle(object: self) }
        set { StyleableSupport.setStyle(object: self, bonMotStyle: newValue) }
    }

}
