# Exploration of a segue alternative

Trivia is a rudimentary app to explore an alternative to using segues in view controllers (VC). While wiring segues using Interface Builder (IB) is fine for small projects the approach has several key drawbacks:

* VC have to have knowledge of the next VC to complete the segue wiring.
* VC have access model concerns outside of their requirements in order to pass data to other VC in segue logic.
* VC aren’t re-usable and typically the storyboard concerns get combined.
* VC get large because of all of these concerns.
* Navigation logic is contained in VC.

This project removes these concerns from the VC into `AppCoordinator.swift` and `AppNavigator.swift`. `AppCoordinator` owns the `AppNavigator`, model/data source, and navigation logic. `AppNavigator` is responsible for pushing, popping, presenting modal and popups, and child VC without knowledge of how they’re connected. This allows for code and storyboard re-use. By allowing VC to configure themselves with a closure that logic is independent of the VC lifecycle and thus testable.
   
## Reasoning
Xcode currently uses a project’s target Main Interface setting and the `@UIApplicationMain` annotation to create and connect a navigation or view controller. The reference to this controller is held by the `AppDelegate`’s `UIWindow` property. Instead we give `AppNavigator.swift` a reference to the root navigation (or view) controller:

```swift
class Navigator {

    let window: UIWindow
    let rootNavigationController: UINavigationController
    ...
}
```

This subtle difference is profound because it enables the `AppNavigator` class to push and present view controllers.

Currently, pushing and presenting view controllers is typically done from `UINavigationController` descendants. This results in view controllers containing code to show other view controllers they probably should be unaware of. What if logic is required to determine which view controller will be shown next? Then view controller will contain that additional logic. This is one reason view controllers get so large and contain so many concerns.

Moving this logic out of the view controller and in to a non UIKit based class has many benefits:

* View controllers are reusable
* View controllers don’t have business logic concerns
* The logic becomes testable
* View controllers shrink

This project applies the ideas above with a simple trivia game example.


### Navigator.swift
This class provides base functionality for navigating between view controllers. These API provide a configuration block so fully formed view controllers can be modified externally after `viewDidLoad` has been called. Since the caller is outside of the view hierarchy, the block's context may include logic and model concerns. Additionally, the controller could take the responsibility of brokering view model to UIViewController and UIView descendants. Using a storyboards just adds a parameter to the API.  Includes normalized push, popover, child, and modal view controller API that encapsulate the details of each. For example, a popover view controller to show a popup menu could be implemented:
```swift
let _: MenuPopoverViewController = presentPopover(anchor: anchor) { vc in
    vc.data = ["Mixed", "Easy", "Medium", "Hard"]
    vc.popoverPresentationController?.permittedArrowDirections = .up
    vc.menuChoice = { choice in
        delegate.setDifficulty(choice)
        vc.dismiss(animated: true) {
            choiceHandler?(choice)
        }
    }
}
```

### AppNavigator.swift
This class is specific to the app and leverages off of the `Navigator`’s base functionality to provide public API to show each view controller in an app e.g. `showModalOptionScreen()`.


### AppCoordinator.swift
This class controls the navigation flow, has injected references to app concerns e.g. model and logic.
```swift
class AppCoordinator {

    let dataSource: DataSource
    let appNavigator: AppNavigator

    func play() {
        dataSource.fetchTriviaModel { data in
            if let model = data {
                self.appNavigator.showGameScreen(model)
            } else {
                self.appNavigator.showNoDataScreen()
            }
        }
    }
    ...
}
```

### Screenshots

![Landing Page](https://user-images.githubusercontent.com/2135673/39156835-d0be650a-470c-11e8-8535-476e6785f78f.jpeg)
![Game Page](https://user-images.githubusercontent.com/2135673/39156834-d0a38d48-470c-11e8-84d4-59983933bb8f.jpeg)

### Trivia Data Links

* [Trivia JSON](https://opentdb.com/api.php?amount=100)
* [Trivia URL generator](https://opentdb.com/api_config.php)
