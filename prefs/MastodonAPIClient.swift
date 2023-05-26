import UIKit
import CryptoKit
import os.log
@_implementationOnly import CepheiPrefs_Private

fileprivate struct WebFingerData: Codable {
	let links: [WebFingerLink]
}

fileprivate struct WebFingerLink: Codable {
	let rel: String
	let type: String?
	let href: String?
}

fileprivate struct MastodonUser: Codable {
	let preferredUsername: String
	let name: String
	let url: String
	let movedTo: String?
	let icon: MastodonUserImage?
}

fileprivate struct MastodonUserImage: Codable {
	enum ImageType: String, Codable {
		case image = "Image"
	}

	let type: ImageType
	let url: String
}

fileprivate struct MastodonUserInfo: Codable {
	let account: String
	let url: URL?
	let imageURL: URL?
}

@objc(HBMastodonAPIClientDelegate)
public protocol MastodonAPIClientDelegate: NSObjectProtocol {
	@objc func mastodonAPIClientDidLoad(account: String, actualAccount: String, url: URL?, profileImage: UIImage?)
}

@objc(HBMastodonAPIClient)
public class MastodonAPIClient: NSObject {

	private static let userAgent = "Cephei/\(cepheiVersion) iOS/\(UIDevice.current.systemVersion) (+https://hbang.github.io/libcephei/)"
	private static let cacheCutoff: TimeInterval = 4 * 24 * 60 * 60

	@objc(sharedInstance)
	public static let shared = MastodonAPIClient()

	private let logger = Logger(subsystem: "ws.hbang.common", category: "MastodonAPIClient")

	private var delegates: [String: NSHashTable<AnyObject>] = [:]
	private var cache: [String: MastodonUserInfo] = [:]
	private var cacheIsDirty = false
	private var writeTimer: Timer?

	static func parseAccount(from string: String) -> (account: String, domain: String)? {
		let components = string.split(separator: "@", maxSplits: 2, omittingEmptySubsequences: true)
		if components.count == 2 {
			return (String(components[0]), String(components[1]))
		}
		return nil
	}

	private override init() {
		super.init()
		do {
			try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
		} catch {
			logger.error("Failed to create cache directory: \(error as NSError)")
		}
		loadCache()
	}

	// MARK: - Cache management

	private let cacheURL: URL = {
		let caches = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		return caches.appendingPathComponent("Cephei/Avatars")
	}()

	private func loadCache() {
		Task.detached {
			if let cacheData = try? Data(contentsOf: self.cacheURL.appendingPathComponent("cache.json")),
				 let cache = try? JSONDecoder().decode([String: MastodonUserInfo].self, from: cacheData) {
				self.cache = cache
			}

			let items = try? FileManager.default.contentsOfDirectory(at: self.cacheURL,
																															 includingPropertiesForKeys: [.attributeModificationDateKey],
																															 options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
			let cutoff = Date(timeIntervalSinceNow: -Self.cacheCutoff)
			var isDirty = false
			for url in items ?? [] {
				if let attributes = try? url.resourceValues(forKeys: [.attributeModificationDateKey]),
					 let date = attributes.contentModificationDate,
					 date.compare(cutoff) == .orderedAscending {
					let basename = url.deletingPathExtension().lastPathComponent
					let splits = basename.split(separator: "!", maxSplits: 1)
					if splits.count == 2 {
						let key = String(splits[0])
						self.cache[key] = nil
						isDirty = true
						try? FileManager.default.removeItem(at: url)
					}
				}
			}

			if isDirty {
				self.saveCache()
			}
		}
	}

	private func saveCache() {
		if !cacheIsDirty {
			return
		}
		do {
			let data = try JSONEncoder().encode(cache)
			try data.write(to: cacheURL.appendingPathComponent("cache.json"))
		} catch {
			logger.error("Failed save cache: \(error as NSError)")
		}
		cacheIsDirty = false
	}

	private func saveCacheDebounced() {
		DispatchQueue.main.async {
			self.writeTimer?.invalidate()
			self.writeTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
				Task.detached(priority: .background) {
					self.saveCache()
				}
			}
		}
	}

	// MARK: - Cache keys

	private func cacheKey(forAccount account: String) -> String? {
		if let (user, host) = Self.parseAccount(from: account) {
			return "acct:\(user)@\(host)"
		}
		return nil
	}

	private func account(forCacheKey cacheKey: String) -> String? {
		if let range = cacheKey.range(of: "acct:") {
			return String(cacheKey[range.upperBound...])
		}
		return nil
	}

	private func sha256(for url: URL) -> String {
		SHA256.hash(data: url.absoluteString.data(using: .utf8)!)
			.prefix(16)
			.reduce("", { string, item in string + String(format: "%02x", item) })
	}

	// MARK: - Queue

	@objc public func queueLookup(forAccount account: String) {
		Task.detached(priority: .userInitiated) {
			if let key = self.cacheKey(forAccount: account),
				 let item = self.cache[key] {
				await self.notifyDelegates(account: account, item: item, image: nil)
			} else {
				await self.fetchWebFinger(forAccount: account)
			}
		}
	}

	@objc public func addDelegate(_ delegate: MastodonAPIClientDelegate, forAccount account: String) {
		if delegates[account] == nil {
			delegates[account] = NSHashTable.weakObjects()
		}
		delegates[account]?.add(delegate)
	}

	@objc public func removeDelegate(_ delegate: MastodonAPIClientDelegate, forAccount account: String?) {
		if let account = account {
			delegates[account]?.remove(delegate)
		} else {
			for delegateSet in delegates.values {
				delegateSet.remove(delegate)
			}
		}
	}

	private func notifyDelegates(account: String, item: MastodonUserInfo, image: UIImage?) async {
		if let delegateSet = delegates[account] {
			for delegate in delegateSet.allObjects {
				if let delegate = delegate as? MastodonAPIClientDelegate {
					var finalImage = image
					if finalImage == nil,
						 let imageURL = item.imageURL {
						finalImage = await self.fetchProfileImage(forAccount: account, atURL: imageURL)
					}
					await MainActor.run { [finalImage] in
						delegate.mastodonAPIClientDidLoad(account: account,
																							actualAccount: item.account,
																							url: item.url,
																							profileImage: finalImage)
					}
				}
			}
		}
	}

	// MARK: - Fetching

	private func request(with url: URL, acceptingContentType: String? = nil) -> URLRequest {
		var request = URLRequest(url: url)
		request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
		request.setValue(acceptingContentType, forHTTPHeaderField: "Accept")
		return request
	}

	private func fetchWebFinger(forAccount account: String) async {
		guard let (user, host) = Self.parseAccount(from: account) else {
			return
		}

		var components = URLComponents()
		components.scheme = "https"
		components.host = host
		components.path = "/.well-known/webfinger"
		components.queryItems = [URLQueryItem(name: "resource", value: "acct:\(user)@\(host)")]

		guard let url = components.url else {
			return
		}

		do {
			let (data, _) = try await URLSession.shared.data(for: request(with: url, acceptingContentType: "application/json"))
			let json = try JSONDecoder().decode(WebFingerData.self, from: data)
			if let selfLink = json.links.first(where: { $0.rel == "self" && $0.type == "application/activity+json" }),
				 let url = URL(string: selfLink.href ?? "") {
				await self.fetchProfile(forAccount: account, profileURL: url)
			}
		} catch {
			logger.error("Failed to get webfinger for account \(account): \(error as NSError)")
		}
	}

	private func fetchProfile(forAccount account: String, profileURL url: URL) async {
		guard let key = cacheKey(forAccount: account) else {
			return
		}

		do {
			let (data, _) = try await URLSession.shared.data(for: request(with: url, acceptingContentType: "application/activity+json"))
			let json = try JSONDecoder().decode(MastodonUser.self, from: data)
			if let movedTo = URL(string: json.movedTo ?? "") {
				await fetchProfile(forAccount: account, profileURL: movedTo)
				return
			}

			guard let userURL = URL(string: json.url) else {
				return
			}

			let (_, host) = Self.parseAccount(from: account)!
			let userInfo = MastodonUserInfo(account: "@\(json.preferredUsername)@\(userURL.host ?? host)",
																			url: userURL,
																			imageURL: URL(string: json.icon?.url ?? ""))
			cache[key] = userInfo
			cacheIsDirty = true
			var image: UIImage?
			if let imageURL = userInfo.imageURL {
				image = await fetchProfileImage(forAccount: account, atURL: imageURL)
			}
			await notifyDelegates(account: account, item: userInfo, image: image)
			saveCacheDebounced()
		} catch {
			logger.error("Failed to get profile for account \(account): \(error as NSError)")
		}
	}

	private func fetchProfileImage(forAccount account: String, atURL url: URL) async -> UIImage? {
		let cacheFilename = "\(account)!\(sha256(for: url))"
		let localURL = cacheURL.appendingPathComponent(cacheFilename)
		if let data = try? Data(contentsOf: localURL),
			 let image = UIImage(data: data) {
			return image
		}

		do {
			let (data, _) = try await URLSession.shared.data(for: request(with: url))
			if let image = UIImage(data: data) {
				try data.write(to: localURL)
				return image
			}
		} catch {
			logger.error("Failed to get profile image for account \(account): \(error as NSError)")
		}
		return nil
	}

}
