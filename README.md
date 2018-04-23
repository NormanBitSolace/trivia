# Trivia

Trivia is a redimentary app that I’m using to explore the notion that Xcode should auto generate an AppNavigator.swift file alongside AppDelegate.swift when creating a new "Single View App" project.
   
## Reasoning
Xcode currently uses a project’s target Main Interface setting to create a navigation or view controller. The reference to this controller is held by the `AppDelegate`’s `UIWindow` property. Suppose creating a new "Single View App" Xcode project auto generated an `AppNavigator.swift` file alongside `AppDelegate.swift`. `AppNavigator.swift` would contain a reference to the root navigation (or view) controller.

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


```
My personal hope is that these independent and resuable view controllers would cause the development community would catch fire sharing view controllers.
```

This project applies the ideas above with a simple trivia game example.


### Navigator.swift
This class provides base functionality for navigating between view controllers. These API provide a configuration block so fully formed view controllers can be modified externally after `viewDidLoad` has been called. Since the caller is outside of the view hierarchy, the block's context may include logic and data which can be simplified to immutable view model. Using a storyboards just adds a parameter to the API.  Specific normalized API for popovers, child, and modal view controllers can encapsulate the details to display each e.g. showing a popup menu:
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
This class controls the navigation flow, has references to app concerns e.g. data and logic.
```swift
class AppCoordinator {

    let dataSource: DataSource
    let appNavigator: AppNavigator

    func play() {
        dataSource.fetchTriviaModel { model in
            if let model = model {
                self.appNavigator.showGameScreen(model)
            } else {
                self.appNavigator.showNoDataScreen()
            }
        }
    }
    ...
}
```
![Landing Page](https://user-images.githubusercontent.com/2135673/39156835-d0be650a-470c-11e8-8535-476e6785f78f.jpeg)
![Game Page](https://user-images.githubusercontent.com/2135673/39156834-d0a38d48-470c-11e8-84d4-59983933bb8f.jpeg)

### Links

* [Trivia JSON](https://opentdb.com/api.php?amount=100)
* [Trivia URL generator](https://opentdb.com/api_config.php)
