import UIKit

extension UIViewController {

    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }

    func addMessage(_ message: String, toView view: UIView) {
        let label = UILabel(frame: .zero)
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 19)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    public func removeChildViewController() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}
