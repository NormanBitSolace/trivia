import UIKit

class GenericTableViewController: UITableViewController {

    var numberOfSections = 1
    var numberOfRowsInSection: ((Int) -> Int)?
    var configureCell: ((UITableViewCell, IndexPath) -> Void)?
    var touchHandler: ((IndexPath) -> Void)?

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRowsInSection = numberOfRowsInSection else { fatalError() }
        return numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let configureCell = configureCell else { fatalError() }
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "generic")
        configureCell(cell, indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let touchHandler = touchHandler {
            touchHandler(indexPath)
        }
    }
}

class GenericPopoverTableViewController: GenericTableViewController, UIPopoverPresentationControllerDelegate {

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

class MenuPopoverViewController: GenericPopoverTableViewController {

    var data: [String]!
    var menuChoice: ((String) -> Void)!

    override init(style: UITableViewStyle) {
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numberOfRowsInSection = { _ in return self.data.count }
        configureCell = { cell, indexPath in
            cell.textLabel?.text = self.data[indexPath.row]
        }
        touchHandler = { indexPath in
            self.menuChoice(self.data[indexPath.row])
        }
        tableView.isScrollEnabled = false
        let rowHeight = 44
        tableView.rowHeight = CGFloat(rowHeight)
        preferredContentSize = CGSize(width: 140, height: rowHeight * data.count)
    }

}
