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
      
    switch call.method {
    case "delete":
        guard let key = arguments["key"] as? String, let auth = arguments["auth"] as? Bool else {
            result(nil)
            return
        }
        
        let success = Keychain.deleteKeychainValue(key: key, authRequired: auth)
        result(success)
    case "fetch":
        guard let key = arguments["key"] as? String, let auth = arguments["auth"] as? Bool else {
            result(nil)
            return
        }
        
        let res = Keychain.fetchKeychainValue(key: key, authRequired: auth)
        result(res)
    case "set":
        guard let key = arguments["key"] as? String, let data = arguments["value"] as? String, let auth = arguments["auth"] as? Bool else {
            result(nil)
            return
        }
        
        let success = Keychain.setKeychainValue(key: key, value: data, requireAuth: auth)
        result(success)
    case "update":
        guard let key = arguments["key"] as? String, let data = arguments["value"] as? String, let auth = arguments["auth"] as? Bool else {
            result(nil)
            return
        }
        
        let success = Keychain.updateKeychainValue(key: key, value: data, authRequired: auth)
        result(success)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

class Keychain {
    public static func deleteKeychainValue(key: String, authRequired: Bool) -> Bool {
        let bundleID: String = Bundle.main.bundleIdentifier ?? "keymaster"
        let account = "\(bundleID).\(key)"
        
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
        
        if SecItemDelete(query as CFDictionary) == noErr {
            return true
        }
        
        return false
    }
    
    public static func fetchKeychainValue(key: String, authRequired: Bool) -> String? {
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
        ]
        
        if (!authRequired) {
            query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUISkip
        }
        
        var item: CFTypeRef?
        
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            if let keychainItem = item as? [String: Any], let rawValue = keychainItem[kSecValueData as String] as? Data, let value = String(data: rawValue, encoding: .utf8) {
                return value
            }
            
            return nil
        }
        
        return nil
    }
    
    public static func setKeychainValue(key: String, value: String, requireAuth: Bool) -> Bool {
        let bundleID: String = Bundle.main.bundleIdentifier ?? "keymaster"
        let account = "\(bundleID).\(key)"
        
        let data = value.data(using: .utf8)!
        
        var attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrAccessControl as String: access,
            kSecValueData as String: data,
        ]
        
        if (requireAuth) {
            attributes[kSecAttrAccessControl as String] = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, .userPresence, nil)!
        }
        
        let res = SecItemAdd(attributes as CFDictionary, nil)
        
        if res == noErr { return true }
        return false
    }
    
    public static func updateKeychainValue(key: String, value: String, authRequired: Bool) -> Bool {
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
        if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == noErr {
            return true
        }
        
        return false
    }
}
