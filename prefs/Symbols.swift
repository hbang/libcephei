import UIKit
import CepheiUI
@_implementationOnly import CepheiPrefs_Private

fileprivate protocol SymbolWeight {
	var symbolWeightValue: UIImage.SymbolWeight? { get }
}

fileprivate protocol SymbolScale {
	var symbolScaleValue: UIImage.SymbolScale?   { get }
}

extension Int: SymbolWeight, SymbolScale {
	var symbolWeightValue: UIImage.SymbolWeight? { UIImage.SymbolWeight(rawValue: self) }
	var symbolScaleValue: UIImage.SymbolScale?   { UIImage.SymbolScale(rawValue: self) }
}

extension String: SymbolWeight, SymbolScale {
	var symbolWeightValue: UIImage.SymbolWeight? {
		switch self {
		case "UIImageSymbolWeightUltraLight", "ultraLight": return .ultraLight
		case "UIImageSymbolWeightThin", "thin":             return .thin
		case "UIImageSymbolWeightLight", "light":           return .light
		case "UIImageSymbolWeightRegular", "regular":       return .regular
		case "UIImageSymbolWeightMedium", "medium":         return .medium
		case "UIImageSymbolWeightSemibold", "semibold":     return .semibold
		case "UIImageSymbolWeightBold", "bold":             return .bold
		case "UIImageSymbolWeightHeavy", "heavy":           return .heavy
		case "UIImageSymbolWeightBlack", "black":           return .black
		default:                                            return nil
		}
	}

	var symbolScaleValue: UIImage.SymbolScale? {
		switch self {
		case "UIImageSymbolScaleSmall", "small":   return .small
		case "UIImageSymbolScaleMedium", "medium": return .medium
		case "UIImageSymbolScaleLarge", "large":   return .large
		default:                                   return nil
		}
	}
}

@objc(HBSymbolRenderer)
public class SymbolRenderer: NSObject {

	@objc public static func makeIcon(backgroundColor: UIColor, isBig: Bool, glyph: UIImage?) -> UIImage {
		let iconSize = isBig ? 40 : 29
		let iconRect = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)

		return UIGraphicsImageRenderer(size: iconRect.size)
			.image { context in
				backgroundColor.setFill()
				context.fill(iconRect)

				if let glyph = glyph {
					// Scale to fit 80% of the icon size
					var glyphSize = CGSize(width: ceil(CGFloat(iconSize) * 0.8),
																height: ceil(CGFloat(iconSize) * 0.8))
					if glyph.size.width > glyph.size.height {
						glyphSize.height /= glyph.size.width / glyph.size.height
					} else if glyph.size.height > glyph.size.width {
						glyphSize.width /= glyph.size.height / glyph.size.width
					}
					let glyphRect = iconRect.insetBy(dx: (CGFloat(iconSize) - glyphSize.width) / 2,
																					dy: (CGFloat(iconSize) - glyphSize.height) / 2)
					glyph.draw(in: glyphRect)
				}
			}
			._applicationIconImage(forFormat: isBig ? .spotlight : .small,
														 precomposed: true,
														 scale: UIScreen.main.scale)
	}

	static func symbolImage(from dictionary: [String: Any]) -> UIImage? {
		guard let name = dictionary["name"] as? String else {
			return nil
		}

		let pointSize = dictionary["pointSize"] as? Double ?? 20
		let weight = (dictionary["weight"] as? SymbolWeight)?.symbolWeightValue ?? .regular
		let scale = (dictionary["scale"] as? SymbolScale)?.symbolScaleValue ?? .medium

		// Tint color: If we have one, use original mode, otherwise inherit tint color via template mode.
		let tintColor = UIColor(propertyListValue: dictionary["tintColor"] as? CepheiUI.ColorPropertyListValue ?? "")
		let renderingMode: UIImage.RenderingMode = tintColor == nil ? .alwaysTemplate : .alwaysOriginal

		let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)

		guard let symbolImage = UIImage(systemName: name, withConfiguration: configuration) else {
			return nil
		}

		// Background color
		if let backgroundColorValue = dictionary["backgroundColor"] as? CepheiUI.ColorPropertyListValue,
			 let backgroundColor = UIColor(propertyListValue: backgroundColorValue) {
			let tintedSymbolImage = symbolImage.withTintColor(tintColor ?? .white, renderingMode: renderingMode)
			return makeIcon(backgroundColor: backgroundColor, isBig: false, glyph: tintedSymbolImage)
		}
		return symbolImage.withTintColor(tintColor ?? .black, renderingMode: renderingMode)
	}

}
