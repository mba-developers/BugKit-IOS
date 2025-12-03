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
    private var observer: NSObjectProtocol?
    
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
        if floatingButtonWindow != nil { return }
        
        let activeScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        
        if let windowScene = activeScene {
            createWindow(in: windowScene)
        } else {
            if let existing = observer { NotificationCenter.default.removeObserver(existing) }
            observer = NotificationCenter.default.addObserver(
                forName: UIScene.didActivateNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.showFloatingButton()
                }
            }
        }
    }
    
    private func createWindow(in windowScene: UIWindowScene) {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
        
        let window = UIWindow(windowScene: windowScene)
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Initial Position (Bottom Right)
        let buttonSize: CGFloat = 60
        window.frame = CGRect(x: screenWidth - buttonSize - 20, y: screenHeight - 150, width: buttonSize, height: buttonSize)
        window.windowLevel = UIWindow.Level.statusBar + 100
        window.backgroundColor = .clear
        
        if #available(iOS 14.0, *) {
            let button = FloatingButtonView() // Simple View
            let controller = UIHostingController(rootView: button)
            controller.view.backgroundColor = .clear
            window.rootViewController = controller
            
            // --- ATTACH GESTURES TO THE WINDOW ROOT VIEW ---
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            
            controller.view.addGestureRecognizer(panGesture)
            controller.view.addGestureRecognizer(tapGesture)
        }
        
        window.isHidden = false
        window.makeKeyAndVisible()
        self.floatingButtonWindow = window
    }
    
    @objc private func handleTap() {
        triggerReport()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = floatingButtonWindow else { return }
        let translation = gesture.translation(in: window)
        
        switch gesture.state {
        case .began, .changed:
            // Move the Window center
            window.center = CGPoint(x: window.center.x + translation.x, y: window.center.y + translation.y)
            gesture.setTranslation(.zero, in: window)
            
        case .ended, .cancelled:
            // Snap Logic
            let screenWidth = UIScreen.main.bounds.width
            let buttonWidth = window.frame.width
            
            // Determine closest edge
            let finalX: CGFloat
            if window.center.x < screenWidth / 2 {
                finalX = buttonWidth / 2 + 10 // Left Edge + padding
            } else {
                finalX = screenWidth - (buttonWidth / 2) - 10 // Right Edge - padding
            }
            
            // Animate Snap
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                window.center = CGPoint(x: finalX, y: window.center.y)
            }
            
        default: break
        }
    }
    
    private func hideFloatingButton() {
        floatingButtonWindow?.isHidden = true
        floatingButtonWindow = nil
    }
}

extension UIWindow {
    static func enableShakeDetection() { }
    
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

