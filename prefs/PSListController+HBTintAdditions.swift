import Preferences

public extension PSListController {

	/// The appearance settings for the view controller.
	///
	/// This should only be set in an init or viewDidLoad method of the view controller. The result when
	/// this property or its properties are changed after the view has appeared is undefined.
	@nonobjc
	var appearanceSettings: AppearanceSettings? {
		get { perform(NSSelectorFromString("hb_appearanceSettings"))?.takeUnretainedValue() as? AppearanceSettings }
		set { perform(NSSelectorFromString("hb_setAppearanceSettings:"), with: newValue) }
	}

}
