import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        
//        let taskListModule = TaskRouter.createModule(oldTitle: "dfalkjd", oldInfo: "flakdjsf", isNewTask: true)
//        let navVC = UINavigationController(rootViewController: taskListModule)
//        
//        window = UIWindow(windowScene: windowScene)
//        window?.rootViewController = navVC
//        window?.makeKeyAndVisible()
        window = UIWindow(windowScene: windowScene)
        let navVC = UINavigationController(rootViewController: AllTasksViewController())
        navVC.modalPresentationStyle = .fullScreen
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

