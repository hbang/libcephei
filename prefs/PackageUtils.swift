import os.log

@_cdecl("shellEscape")
func shellEscape(_ input: [String]) -> String {
	input
		.map { "'" + $0.replacingOccurrences(of: "'", with: "'\\''") + "'" }
		.joined(separator: " ")
}

@_cdecl("getFieldsForPackage")
func getFieldsForPackage(_ package: String, _ fields: [String]) -> [String: String]? {
	let format = fields
		.map { "${\($0)}" }
		.joined(separator: "\n")
	guard let output = HBOutputForShellCommand(shellEscape(["\(installPrefix)/usr/bin/dpkg-query", "-Wf", format, package])) else {
		return nil
	}

	let lines = output.components(separatedBy: "\n")
	guard lines.count == fields.count else {
		return nil
	}

	var result = [String: String]()
	for (field, line) in zip(fields, lines) {
		result[field] = line
	}
	return result
}

@_cdecl("getFieldForPackage")
func getFieldForPackage(_ package: String, _ field: String) -> String? {
	getFieldsForPackage(package, [field])?[field]
}

@_cdecl("resolvePackageForFile")
func resolvePackageForFile(_ file: String) -> String? {
	// Un-resolve /private/preboot/…/procursus to /var/jb
	var resolvedURL = URL(fileURLWithPath: file)
	let installPrefixURL = URL(fileURLWithPath: installPrefix)
	let resolvedPrefix = installPrefixURL.resolvingSymlinksInPath().path
	if file.hasPrefix(resolvedPrefix) {
		resolvedURL = installPrefixURL
			.appendingPathComponent(String(file.dropFirst(resolvedPrefix.count + 1)))
	}

	guard let output = HBOutputForShellCommand(shellEscape(["\(installPrefix)/usr/bin/dpkg-query", "-S", resolvedURL.path])) else {
		return nil
	}

	if let range = output.range(of: ":") {
		return String(output[..<range.lowerBound])
	}
	return nil
}
