import Foundation

/// Manages persistent user data storage using iCloud Key-Value Store with UserDefaults fallback.
/// Ensures data persists across device changes while maintaining backward compatibility.
@MainActor
final class UserStorageManager {

    // MARK: - Singleton

    static let shared = UserStorageManager()

    // MARK: - Storage Keys

    private enum StorageKey {
        static let userID = "buky_user_id"
    }

    // MARK: - Cached Properties

    /// The user's persistent UUID, loaded once at initialization and cached for the app lifecycle.
    /// This ensures we don't read from storage on every access.
    let userID: String

    // MARK: - Storage References

    private let iCloudStore = NSUbiquitousKeyValueStore.default
    private let localStore = UserDefaults.standard

    // MARK: - Initialization

    private init() {
        // Load UUID with migration strategy:
        // 1. Check iCloud first (preferred, persists across devices)
        // 2. Fall back to UserDefaults (existing installations)
        // 3. Generate new UUID if neither exists
        // 4. Always save to both stores for redundancy

        if let iCloudUserID = iCloudStore.string(forKey: StorageKey.userID), !iCloudUserID.isEmpty {
            // UUID exists in iCloud - use it and ensure it's in UserDefaults too
            self.userID = iCloudUserID
            if localStore.string(forKey: StorageKey.userID) != iCloudUserID {
                localStore.set(iCloudUserID, forKey: StorageKey.userID)
            }
        } else if let localUserID = localStore.string(forKey: StorageKey.userID), !localUserID.isEmpty {
            // UUID exists only in UserDefaults - migrate to iCloud
            self.userID = localUserID
            iCloudStore.set(localUserID, forKey: StorageKey.userID)
            iCloudStore.synchronize()
        } else {
            // No UUID found - generate new one and save to both stores
            let newUserID = UUID().uuidString
            self.userID = newUserID

            iCloudStore.set(newUserID, forKey: StorageKey.userID)
            iCloudStore.synchronize()

            localStore.set(newUserID, forKey: StorageKey.userID)
        }

        // Listen for iCloud changes (e.g., when user signs in on new device)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloudStore
        )
    }

    // MARK: - iCloud Sync

    @objc private func iCloudStoreDidChange(notification: Notification) {
        // Note: Since userID is a let constant loaded at init, we only sync on app launch.
        // If the UUID changes in iCloud while the app is running, we intentionally
        // don't update the in-memory value to avoid inconsistencies during the session.
        // The updated value will be picked up on next app launch.

        guard let userInfo = notification.userInfo,
              let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }

        // Only handle external changes (from other devices or account changes)
        if reasonForChange == NSUbiquitousKeyValueStoreServerChange ||
           reasonForChange == NSUbiquitousKeyValueStoreInitialSyncChange {

            // Log for debugging but don't modify cached userID
            if let updatedUserID = iCloudStore.string(forKey: StorageKey.userID),
               updatedUserID != userID {
                print("[UserStorageManager] iCloud UUID changed externally. Will take effect on next launch.")
            }
        }
    }

    // MARK: - Future Storage Methods

    /// Saves a string value to both iCloud and UserDefaults
    func saveString(_ value: String?, forKey key: String) {
        if let value = value {
            iCloudStore.set(value, forKey: key)
            iCloudStore.synchronize()
            localStore.set(value, forKey: key)
        } else {
            iCloudStore.removeObject(forKey: key)
            iCloudStore.synchronize()
            localStore.removeObject(forKey: key)
        }
    }

    /// Retrieves a string value, checking iCloud first, then UserDefaults
    func getString(forKey key: String) -> String? {
        if let iCloudValue = iCloudStore.string(forKey: key), !iCloudValue.isEmpty {
            return iCloudValue
        }
        return localStore.string(forKey: key)
    }

    /// Saves a boolean value to both iCloud and UserDefaults
    func saveBool(_ value: Bool, forKey key: String) {
        iCloudStore.set(value, forKey: key)
        iCloudStore.synchronize()
        localStore.set(value, forKey: key)
    }

    /// Retrieves a boolean value, checking iCloud first, then UserDefaults
    func getBool(forKey key: String) -> Bool {
        // Check if key exists in iCloud
        if iCloudStore.object(forKey: key) != nil {
            return iCloudStore.bool(forKey: key)
        }
        return localStore.bool(forKey: key)
    }
}
