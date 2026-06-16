import Flutter
import UIKit

@objc(SceneDelegate)
class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else {
      return
    }

    if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      appDelegate.handleIncomingURL(url, rootViewController: window?.rootViewController)
    {
      return
    }

    super.scene(scene, openURLContexts: URLContexts)
  }
}
