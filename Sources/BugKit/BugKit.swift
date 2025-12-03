// The Swift Programming Language
// https://docs.swift.org/swift-book

#if canImport(UIKit)
import UIKit
import SwiftUI

@MainActor
public class BugKit {
    
    public static let shared = BugKit()
    
    var baseUrl: String?
    var apiKey: String?
    var isShakeEnabled = true
    var isFloatingButtonEnabled = false
    
    private var floatingButtonWindow: UIWindow?
    
    private init() {}
    
    public static func start(with apiKey: String, baseUrl: String) {
        shared.apiKey = apiKey
        shared.baseUrl = baseUrl
        
        UIWindow.enableShakeDetection()
        CrashHandler.setup()
    }
    
    public static func setInvocationOptions(shake: Bool, floatingButton: Bool) {
        shared.isShakeEnabled = shake
        shared.isFloatingButtonEnabled = floatingButton
        
        if floatingButton {
            shared.showFloatingButton()
        } else {
            shared.hideFloatingButton()
        }
    }
    
    internal func triggerReport() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let screenshot = window.takeScreenshot()
        
        if #available(iOS 14.0, *) {
            let reportView = ReportView(initialAttachment: screenshot)
            let hostingController = UIHostingController(rootView: reportView)
            hostingController.modalPresentationStyle = .fullScreen
            window.rootViewController?.present(hostingController, animated: true)
        }
    }
    
    private func showFloatingButton() {
        guard floatingButtonWindow == nil else { return }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.frame = CGRect(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height - 150, width: 60, height: 60)
            window.windowLevel = .alert + 1
            window.backgroundColor = .clear
            
            if #available(iOS 14.0, *) {
                let button = FloatingButtonView { [weak self] in
                    self?.triggerReport()
                }
                let controller = UIHostingController(rootView: button)
                controller.view.backgroundColor = .clear
                window.rootViewController = controller
            }
            
            window.makeKeyAndVisible()
            self.floatingButtonWindow = window
        }
    }
    
    private func hideFloatingButton() {
        floatingButtonWindow?.isHidden = true
        floatingButtonWindow = nil
    }
}

extension UIWindow {
    static func enableShakeDetection() {
        // iOS handles shake automatically via motionEnded
    }
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            Task { @MainActor in
                if BugKit.shared.isShakeEnabled {
                    BugKit.shared.triggerReport()
                }
            }
        }
        super.motionEnded(motion, with: event)
    }
    
    func takeScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
#endif
