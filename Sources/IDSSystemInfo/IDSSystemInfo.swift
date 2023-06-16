//
//  IDSSystemInfo.swift
//  DVSSDKTest
//
//  Created by AKorotkov on 08.06.2023.
//

import Foundation
import UIKit

public class IDSSystemInfo {
    public init() {}
    
    public var platform: String {
        #if os(OSX)
            return "macOS"
        #elseif os(watchOS)
            return "watchOS"
        #elseif os(tvOS)
            return "tvOS"
        #elseif os(iOS)
            #if targetEnvironment(macCatalyst)
                return "macOS - Catalyst"
            #else
                return "iOS"
            #endif
        #endif
    }
    
    public var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    public var moduleVersion: String? {
        Bundle(for: Self.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    public var moduleBuild: String? {
        Bundle(for: Self.self).object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    public var appVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    public var appBuild: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    public var appName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    public var appDisplayName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
    
    public var appBundleID: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
    }
    
    public var appDevelopmentRegion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDevelopmentRegion") as? String
    }
    
    public var appCopyright: String? {
        if let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String {
            return copyright.replacingOccurrences(of: "\\\\n", with: "\n")
        }
        
        return nil
    }
    
    public var systemLanguage: String? {
        return Locale.current.languageCode
    }
    
    public var appLanguage: String? {
        Locale.preferredLanguages.first
    }
    
    /**
     Required: Add "cydia" to LSApplicationQueriesSchemes
     */
    
    public var isJailBroken: Bool {
        if self.isSimulator { return false }
        if JailBrokenHelper.hasCydiaInstalled() { return true }
        if JailBrokenHelper.isContainsSuspiciousApps() { return true }
        if JailBrokenHelper.isSuspiciousSystemPathsExists() { return true }
        return JailBrokenHelper.canEditSystemFiles()
    }
    
    public var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    public var currentTimeZone: String {
        TimeZone.current.identifier
    }
    
    public var isConnectedToVPN: Bool {
        if let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? Dictionary<String, Any>,
           let scopes = settings["__SCOPED__"] as? [String:Any] {
            for (key, _) in scopes {
                if key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") {
                    return true
                }
            }
        }
        return false
    }
    
    public var ipAddress: String? {
        _ipAddress
    }
    private var _ipAddress: String? = nil
    public func updateIPAddress(handler block: ((String?) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            var ip: String? = nil
            let url = URL(string: "https://api.ipify.org/")!
            do {
                ip = try NSString(contentsOf: url, encoding: NSUTF8StringEncoding) as String
            } catch {
                
            }
            
            DispatchQueue.main.async {
                self?._ipAddress = ip
                
                if let block = block {
                    block(ip)
                }
            }
        }
    }
    
    public var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    public var screenScale: CGFloat {
        UIScreen.main.scale
    }
    
    public var deviceOrientation: UIDeviceOrientation {
        UIDevice.current.orientation
    }
}

// MARK: - JailBrokenHelper (https://github.com/developerinsider/isJailBroken/blob/master/IsJailBroken/Extension/UIDevice%2BJailBroken.swift)

fileprivate struct JailBrokenHelper {
    static func hasCydiaInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
    }
    
    static func isContainsSuspiciousApps() -> Bool {
        for path in suspiciousAppsPathToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    static func isSuspiciousSystemPathsExists() -> Bool {
        for path in suspiciousSystemPathsToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    static func canEditSystemFiles() -> Bool {
        let jailBreakText = "Developer Insider"
        do {
            try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    /**
     Add more paths here to check for jail break
     */
    static var suspiciousAppsPathToCheck: [String] {
        return ["/Applications/Cydia.app",
                "/Applications/blackra1n.app",
                "/Applications/FakeCarrier.app",
                "/Applications/Icy.app",
                "/Applications/IntelliScreen.app",
                "/Applications/MxTube.app",
                "/Applications/RockApp.app",
                "/Applications/SBSettings.app",
                "/Applications/WinterBoard.app"
        ]
    }
    
    static var suspiciousSystemPathsToCheck: [String] {
        return ["/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                "/private/var/lib/apt",
                "/private/var/lib/apt/",
                "/private/var/lib/cydia",
                "/private/var/mobile/Library/SBSettings/Themes",
                "/private/var/stash",
                "/private/var/tmp/cydia.log",
                "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                "/usr/bin/sshd",
                "/usr/libexec/sftp-server",
                "/usr/sbin/sshd",
                "/etc/apt",
                "/bin/bash",
                "/Library/MobileSubstrate/MobileSubstrate.dylib"
        ]
    }
}

