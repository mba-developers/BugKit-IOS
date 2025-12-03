//
//  CrashHandler.swift
//  BugKit
//
//  Created by Balavignesh on 03/12/25.
//

import Foundation

private func bugKitUncaughtExceptionHandler(_ exception: NSException) {
    // Capture Crash Details
    let stack = exception.callStackSymbols.joined(separator: "\n")
    let name = exception.name.rawValue
    let reason = exception.reason ?? "Unknown"
    
    let report = """
    CRASH REPORT
    Name: \(name)
    Reason: \(reason)
    Stack Trace:
    \(stack)
    """
    
    // Save to Disk synchronously (App is dying!)
    CrashHandler.saveCrashToDisk(report)
}

class CrashHandler {
    static func setup() {
        NSSetUncaughtExceptionHandler(bugKitUncaughtExceptionHandler)
        
    }
    
    fileprivate static func saveCrashToDisk(_ report: String) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        if let cacheDir = urls.first {
            let fileURL = cacheDir.appendingPathComponent("crash_\(Date().timeIntervalSince1970).txt")
            try? report.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
}
