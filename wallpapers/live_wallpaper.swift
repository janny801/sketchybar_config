import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let htmlPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ""
        let fileURL = URL(fileURLWithPath: htmlPath)

        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )

            // Pin behind all normal desktop icons and apps (desktop wallpaper level)
            window.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.isOpaque = true
            window.backgroundColor = .black
            window.ignoresMouseEvents = true

            let config = WKWebViewConfiguration()
            config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

            let webView = WKWebView(frame: window.contentView!.bounds, configuration: config)
            webView.autoresizingMask = [.width, .height]
            webView.setValue(false, forKey: "drawsBackground")

            if !htmlPath.isEmpty && FileManager.default.fileExists(atPath: htmlPath) {
                webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
            }

            window.contentView?.addSubview(webView)
            window.orderBack(nil)
            windows.append(window)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
