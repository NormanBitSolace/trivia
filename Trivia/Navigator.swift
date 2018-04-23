import UIKit

public typealias Configure<T> = ((_ vc: T) -> Swift.Void)?
public typealias Completion = (() -> Swift.Void)?

class Navigator: NSObject {

    var window: UIWindow!
    var rootNavigationController: UINavigationController!

    func start<T: UIViewController>(vc: T.Type, storyboardName: String? = nil) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        var rootVC: UIViewController
        if let name = storyboardName {
            rootVC = UIViewController.loadStoryboard(name)
        } else {
            rootVC = T.init()
        }
        if let navigationController = rootVC.navigationController {
            rootNavigationController = navigationController
        } else {
            rootNavigationController = UINavigationController(rootViewController: rootVC)
        }
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }
}

extension Navigator {   // PUSH

    @discardableResult
    public func push<T: UIViewController>(animated: Bool = true, configure: Configure<T>) -> T {
        let vc = T.init()
        return push(vc: vc, animated: animated, configure: configure)
    }

    @discardableResult
    public func push<T: UIViewController>(storyboardName: String, animated: Bool = true, configure: Configure<T>) -> T {
        let vc = UIViewController.loadStoryboard(storyboardName) as T
        return push(vc: vc, animated: animated, configure: configure)
    }

    @discardableResult
    private func push<T: UIViewController>(vc: T, animated: Bool = true, configure: Configure<T>) -> T {
        rootNavigationController.applyConfig(vc, configure: configure)
        rootNavigationController.pushViewController(vc, animated: animated)
        return vc
    }
}

extension Navigator {   //  MODAL

    @discardableResult
    public func presentModal<T: UIViewController>(animated: Bool = true, completion: Completion = nil, configure: Configure<T>) -> T {
        let vc = T.init()
        _ = UINavigationController.init(rootViewController: vc)
        rootNavigationController.applyConfig(vc, configure: configure)
        let target = vc.navigationController ?? vc
        rootNavigationController.present(target, animated: animated, completion: completion)
        return vc
    }

    @discardableResult
    public func presentModal<T: UIViewController>(storyboardName: String, wrap: Bool = false, animated: Bool = true, completion: Completion = nil, configure: Configure<T>) -> T {
        let vc = UIViewController.loadStoryboard(storyboardName) as T
        if wrap {
            _ = UINavigationController.init(rootViewController: vc)
        }
        rootNavigationController.applyConfig(vc, configure: configure)
        let target = vc.navigationController ?? vc
        rootNavigationController.present(target, animated: animated, completion: completion)
        return vc
    }
}

extension Navigator {   //  POPOVER

    @discardableResult
    public func presentPopover<T: UIViewController>(anchor: Any, animated: Bool = true, completion: Completion = nil, configure: Configure<T>) -> T {
        let vc = T.init()
        return presentPopover(vc: vc, anchor: anchor, animated: animated, completion: completion, configure: configure)
    }

    @discardableResult
    public func presentPopover<T: UIViewController>(storyboardName: String, anchor: Any, animated: Bool = true, completion: Completion = nil, configure: Configure<T>) -> T {
        let vc = UIViewController.loadStoryboard(storyboardName) as T
        return presentPopover(vc: vc, anchor: anchor, animated: animated, completion: completion, configure: configure)
    }

    @discardableResult
    private func presentPopover<T: UIViewController>(vc: T, anchor: Any, animated: Bool = true, completion: Completion = nil, configure: Configure<T>) -> T {
        let target = vc.navigationController ?? vc
        target.modalPresentationStyle = .popover
        rootNavigationController.applyPopoverConfig(vc, anchor: anchor)
        rootNavigationController.applyConfig(vc, configure: configure)
        rootNavigationController.presentedViewController?.present(target, animated: animated, completion: completion)
        return vc
    }
}

extension Navigator {   //  CHILD

    @discardableResult
    public func addChildViewController<T: UIViewController>(container: UIViewController, animated: Bool = true, configure: Configure<T>) -> T {
        let vc = T.init()
        return addChildViewController(vc: vc, container: container, animated: animated, configure: configure)
    }

    @discardableResult
    public func addChildViewController<T: UIViewController>(storyboardName: String, container: UIViewController, animated: Bool = true, configure: Configure<T>) -> T {
        let vc = UIViewController.loadStoryboard(storyboardName) as T
        return addChildViewController(vc: vc, container: container, animated: animated, configure: configure)
    }

    private func addChildViewController<T: UIViewController>(vc: T, container: UIViewController, animated: Bool = true, configure: Configure<T>) -> T {
        container.addChildViewController(vc)
        rootNavigationController.applyConfig(vc, configure: configure)
        container.view.addSubview(vc.view)
        vc.didMove(toParentViewController: container)
        return vc
    }
}

extension Navigator {   //  ALERT

    func singleButtonAlert(buttonLabel: String, title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonLabel, style: .default, handler: handler)
        alertController.addAction(okAction)
        rootNavigationController.present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {

    static func loadStoryboard<T: UIViewController>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        if let navigationController = vc as? UINavigationController,
            let vc = navigationController.topViewController as? T {
            return vc
        } else if let vc = vc as? T {
            return vc
        } else {
            fatalError(
                """


                    --- Storyboard must have Is Initial View Controller option set to on. ---


                    """
            )
        }
    }

    func applyConfig<T: UIViewController>(_ vc: T, configure: Configure<T>) {
        vc.view.frame = view.bounds
        if let configure = configure {
            vc.loadViewIfNeeded()
            configure(vc)
        }
    }

    var popoverDelegateErrorMessage: String {
        return """


        --- A popover view controller must derive from PopoverViewController OR implement: ---

        extension ViewController: UIPopoverPresentationControllerDelegate {

        public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
        }

        public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
        }
        }

        """
    }

    func applyPopoverConfig(_ vc: UIViewController, anchor: Any) {
        guard let popoverDelegate = vc as? UIPopoverPresentationControllerDelegate else { fatalError(popoverDelegateErrorMessage) }
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = popoverDelegate
        if let barButtonItem = anchor as? UIBarButtonItem {
            vc.popoverPresentationController?.barButtonItem = barButtonItem
        } else if let sourceView = anchor as? UIView {
            vc.popoverPresentationController?.sourceView = sourceView
            vc.popoverPresentationController?.sourceRect = sourceView.bounds
        }
    }
}
