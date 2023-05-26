import UIKit

/// ColorPropertyListValue is a protocol representing types that can be passed to the
/// `UIColor.init(propertyListValue:)` initialiser. `String` and `Array` both conform to this type.
///
/// - see: `UIColor.init(propertyListValue:)`
public protocol ColorPropertyListValue {}

/// A string can represent a `ColorPropertyListValue`.
///
/// - see: `UIColor.init(propertyListValue:)`
extension String: ColorPropertyListValue {}

/// An array of integers can represent a `ColorPropertyListValue`.
///
/// - see: `UIColor.init(propertyListValue:)`
extension Array: ColorPropertyListValue where Element: FixedWidthInteger {}

/// CepheiUI provides extensions to `UIColor` for the purpose of serializing and deserializing
/// colors into representations that can be stored in property lists, JSON, and similar formats.
public extension UIColor {

	/// Initializes and returns a color object using data from the specified object.
	///
	/// The value is expected to be one of:
	///
	/// * An array of 3 or 4 integer RGB or RGBA color components, with values between 0 and 255 (e.g.
	///   `[218, 192, 222]`)
	/// * A CSS-style hex string, with an optional alpha component (e.g. `#DAC0DE` or `#DACODE55`)
	/// * A short CSS-style hex string, with an optional alpha component (e.g. `#DC0` or `#DC05`)
	///
	/// Use `-[UIColor initWithHbcp_propertyListValue:]` to access this method from Objective-C.
	///
	/// - parameter value: The object to retrieve data from. See the discussion for the supported object
	/// types.
	/// - returns: An initialized color object, or nil if the value does not conform to the expected
	/// type. The color information represented by this object is in the device RGB colorspace.
	/// - see: `propertyListValue`
	@nonobjc convenience init?(propertyListValue: ColorPropertyListValue?) {
		if let array = propertyListValue as? [Int], array.count == 3 || array.count == 4 {
			let floats = array.map(CGFloat.init(_:))
			self.init(red: floats[0] / 255,
								green: floats[1] / 255,
								blue: floats[2] / 255,
								alpha: array.count == 4 ? floats[3] : 1)
			return
		} else if var string = propertyListValue as? String {
			if string.count == 4 || string.count == 5 {
				let r = String(repeating: string[string.index(string.startIndex, offsetBy: 1)], count: 2)
				let g = String(repeating: string[string.index(string.startIndex, offsetBy: 2)], count: 2)
				let b = String(repeating: string[string.index(string.startIndex, offsetBy: 3)], count: 2)
				let a = string.count == 5 ? String(repeating: string[string.index(string.startIndex, offsetBy: 4)], count: 2) : "FF"
				string = r + g + b + a
			}

			var hex: UInt64 = 0
			let scanner = Scanner(string: string)
			guard scanner.scanString("#") != nil,
						scanner.scanHexInt64(&hex) else {
				return nil
			}

			if string.count == 9 {
				self.init(red: CGFloat((hex & 0xFF000000) >> 24) / 255,
									green: CGFloat((hex & 0x00FF0000) >> 16) / 255,
									blue: CGFloat((hex & 0x0000FF00) >> 8) / 255,
									alpha: CGFloat((hex & 0x000000FF) >> 0) / 255)
				return
			} else {
				var alpha: Float = 1
				if scanner.scanString(":") != nil,
					 let value = scanner.scanFloat() {
					// Continue scanning to get the alpha component.
					alpha = value
				}

				self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255,
									green: CGFloat((hex & 0x00FF00) >> 8) / 255,
									blue: CGFloat((hex & 0x0000FF) >> 0) / 255,
									alpha: CGFloat(alpha))
				return
			}
		}

		return nil
	}

	/// Maps `init(propertyListValue:)` to Objective-C due to Swift limitations. This is an
	/// implementation detail. Ignore this and use `UIColor(propertyListValue:)` or
	/// `-[UIColor hb_initWithPropertyListValue:]` as per usual.
	///
	/// - parameter value: The object to retrieve data from. See the discussion for the supported
	/// object types.
	/// - returns: An initialized color object, or nil if the value does not conform to the expected
	/// type. The color information represented by this object is in the device RGB colorspace.
	/// - see: `init(propertyListValue:)`
	@objc(hb_initWithPropertyListValue:)
	convenience init?(_propertyListValueObjC propertyListValue: Any?) {
		if let value = propertyListValue as? String {
			self.init(propertyListValue: value)
		} else if let value = propertyListValue as? [Int] {
			self.init(propertyListValue: value)
		} else {
			return nil
		}
	}

	@objc(hb_colorWithPropertyListValue:)
	class func _colorWithPropertyListValueObjC(_ propertyListValue: Any?) -> UIColor? {
		UIColor(_propertyListValueObjC: propertyListValue)
	}

	/// Initializes and returns a dynamic color object using the provided interface style variants.
	///
	/// This color dynamically changes based on the interface style on iOS 13 and newer. If dynamic
	/// colors are not supported by the operating system, the value for UIUserInterfaceStyleLight or
	/// UIUserInterfaceStyleUnspecified is returned.
	///
	/// Example:
	///
	/// ```swift
	/// let myColor = UIColor(interfaceStyleVariants: [
	/// 	.light: .systemRed,
	/// 	.dark: .systemOrange
	/// ])
	/// ```
	///
	/// ```objc
	/// UIColor *myColor = [UIColor hb_colorWithInterfaceStyleVariants:@{
	/// 	@(UIUserInterfaceStyleLight): [UIColor systemRedColor],
	/// 	@(UIUserInterfaceStyleDark): [UIColor systemOrangeColor]
	/// }];
	/// ```
	///
	/// @param variants A dictionary of interface style keys and UIColor values.
	/// @return An initialized dynamic color object, or the receiver if dynamic colors are unsupported
	/// by the current operating system.
	@nonobjc convenience init(interfaceStyleVariants variants: [UIUserInterfaceStyle: UIColor]) {
		self.init(dynamicProvider: { traitCollection in
			let style = traitCollection.userInterfaceStyle
			return variants[style] ?? variants[.light] ?? variants[.unspecified]!
		})
	}

	@objc(hb_initWithInterfaceStyleVariants:)
	convenience init(_interfaceStyleVariantsObjC variants: [NSNumber: UIColor]) {
		self.init(interfaceStyleVariants: Dictionary(uniqueKeysWithValues: variants.map { (UIUserInterfaceStyle(rawValue: $0.intValue)!, $1) }))
	}

	@objc(hb_colorWithInterfaceStyleVariants:)
	class func _colorWithInterfaceStyleVariantsObjC(_ variants: [NSNumber: UIColor]) -> UIColor {
		UIColor(_interfaceStyleVariantsObjC: variants)
	}

	private static let dynamicColorClass = NSClassFromString("UIDynamicColor") as! NSObject.Type

	private var isDynamicColor: Bool { isKind(of: Self.dynamicColorClass) }

	/// Initializes and returns a dynamic color object, with saturation decreased by 4% in the dark
	/// interface style.
	///
	/// @return If the color is already a dynamic color, returns the receiver. Otherwise, a new dynamic
	/// color object.
	/// @see `+hb_colorWithInterfaceStyleVariants:`
	@objc(hb_colorWithDarkInterfaceVariant)
	func _withDarkInterfaceVariantObjC() -> UIColor {
		withDarkInterfaceVariant(nil)
	}

	/// Initializes and returns a dynamic color object, with the specified variant color for the dark
	/// interface style.
	///
	/// If no color is specified, the color is desaturated by 4% in the dark interface style.
	///
	/// If the color is already a dynamic color, and no color is specified, returns the receiver.
	/// Otherwise, returns a new dynamic color object with the specified color for the dark interface
	/// style.
	///
	/// Example:
	///
	/// ```swift
	/// let myColor = UIColor.systemRed.withDarkInterfaceVariant()
	/// // or
	/// let otherColor = UIColor.systemRed.withDarkInterfaceVariant(.systemOrange)
	/// ```
	///
	/// ```objc
	/// UIColor *myColor = [[UIColor systemRedColor] hb_colorWithDarkInterfaceVariant];
	/// // or
	/// UIColor *otherColor = [[UIColor systemRedColor] hb_colorWithDarkInterfaceVariant:[UIColor systemOrangeColor]];
	/// ```
	///
	/// @param darkColor The color to use in the dark interface style.
	/// @return A new dynamic color object.
	/// @see `-hb_colorWithInterfaceStyleVariants:`
	@objc(hb_colorWithDarkInterfaceVariant:)
	func withDarkInterfaceVariant(_ darkColor: UIColor? = nil) -> UIColor {
		if darkColor == nil && isDynamicColor {
			// Don’t apply an automatic dark color, we already are a dynamic color.
			return self
		}

		let newDarkColor: UIColor
		if let darkColor = darkColor {
			newDarkColor = darkColor
		} else {
			var (h, s, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
			getHue(&h, saturation: &s, brightness: &b, alpha: &a)
			newDarkColor = UIColor(hue: h, saturation: max(0.20, s * 0.96), brightness: b, alpha: a)
		}

		return UIColor(interfaceStyleVariants: [
			.light: self,
			.dark: newDarkColor
		])
	}

}
