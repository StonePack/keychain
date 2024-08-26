import Flutter
import LocalAuthentication
import Security
import UIKit

public class KeymasterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "keymaster", binaryMessenger: registrar.messenger())
    let instance = KeymasterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as! Dictionary<String, Any>
    
    let auth = arguments["auth"] as? Bool ?? false
    let data = arguments["value"] as? String
    let key = arguments["key"] as? String
      
    if (key == nil) {
        return result(nil)
    }
      
    switch call.method {
    case "delete":
        result(Keychain.deleteKeychainValue(key: key!, authRequired: auth))
    case "fetch":
        result(Keychain.fetchKeychainValue(key: key!, authRequired: auth))
    case "set":
        if (data == nil) {
            return result(nil)
        }

        result(Keychain.setKeychainValue(key: key!, value: data!, requireAuth: auth))
    case "update":
        if (data == nil) {
            return result(nil)
        }
        
        result(Keychain.updateKeychainValue(key: key!, value: data!, authRequired: auth))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

class Keychain {
    static let access = SecAccessControlCreateWithFlags(
      nil,  // Use the default allocator.
      kSecAttrAccessibleWhenUnlocked,
      .userPresence,
      nil
    );
    
    public static func deleteKeychainValue(key: String, authRequired: Bool) -> String {
        let bundleID: String = Bundle.main.bundleIdentifier ?? "keymaster"
        let account = "\(bundleID).\(key)"
        
        let context = LAContext()
        context.localizedReason = "Authenticate to update keychain"
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecUseAuthenticationContext as String: context,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUI
        ]
        
        if (!authRequired) {
            query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUISkip
        }
        
        let result = SecItemDelete(query as CFDictionary)
        return result == noErr ? "true" : SecCopyErrorMessageString(result, nil).debugDescription
    }
    
    public static func fetchKeychainValue(key: String, authRequired: Bool) -> String {
        let bundleID: String = Bundle.main.bundleIdentifier ?? "keymaster"
        let account = "\(bundleID).\(key)"
        
        let context = LAContext()
        context.localizedReason = "Authenticate to read from keychain"
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUI
        ]
        
        if (!authRequired) {
            query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUISkip
        }
        
        var item: CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        
        if (result == noErr) {
            if let keychainItem = item as? [String: Any], let rawValue = keychainItem[kSecValueData as String] as? Data, let value = String(data: rawValue, encoding: .utf8) {
                return value
            }
            
            return "secCopyErr: item data invalid"
        }
        
        let err = SecCopyErrorMessageString(result, nil)
        return "secCopyErr: \(err.debugDescription)"
    }
    
    public static func setKeychainValue(key: String, value: String, requireAuth: Bool) -> String {
        let bundleID: String = Bundle.main.bundleIdentifier ?? "keymaster"
        let account = "\(bundleID).\(key)"
        
        let context = LAContext()
        context.localizedReason = "Authenticate to read from keychain"
        
        let data = value.data(using: .utf8)!
        
        var attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecUseAuthenticationContext as String: context,
        ]
        
        if (requireAuth) {
            attributes[kSecAttrAccessControl as String] = access
        }
        
        let result = SecItemAdd(attributes as CFDictionary, nil)
        if (result == errSecDuplicateItem) {
            return updateKeychainValue(key: key, value: value, authRequired: requireAuth)
        }
        
        
        return result == noErr ? "true" : SecCopyErrorMessageString(result, nil).debugDescription

    }
    
    public static func updateKeychainValue(key: String, value: String, authRequired: Bool) -> String {
        let bundleID: String = Bundle.main.bundleIdentifier ?? "keymaster"
        let account = "\(bundleID).\(key)"
        
        let data = value.data(using: .utf8)!
        
        let context = LAContext()
        context.localizedReason = "Authenticate to update keychain"
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecUseAuthenticationContext as String: context,
        ]
        
        if (!authRequired) {
            query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUISkip
        }
        
        let attributes: [String: Any] = [kSecValueData as String: data]
        
        let result = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return result == noErr ? "true" : SecCopyErrorMessageString(result, nil).debugDescription
    }
}
