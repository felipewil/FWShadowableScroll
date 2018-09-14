# FWShadowableScroll

[![Version](https://img.shields.io/cocoapods/v/FWShadowableScroll.svg?style=flat)](https://cocoapods.org/pods/FWShadowableScroll)
[![License](https://img.shields.io/cocoapods/l/FWShadowableScroll.svg?style=flat)](https://cocoapods.org/pods/FWShadowableScroll)
[![Platform](https://img.shields.io/cocoapods/p/FWShadowableScroll.svg?style=flat)](https://cocoapods.org/pods/FWShadowableScroll)

## Example

![](https://thumbs.gfycat.com/AlarmingShockedGelada-size_restricted.gif)

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Basic configuration with a UIScrollView:
```
@IBOutlet weak var scrollView: UIScrollView!

override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollView.shouldShowScrollShadow = true
    scrollView.shadowRadius = 10.0 // Default is 4.0
    scrollView.shadowHeight = 10.0 // Default is 4.0
}
```

**Even easier**: `shouldShowScrollShadow` is an `IBInspectable` so it can be set through Interface Builder.

## Installation

FWShadowableScroll is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FWShadowableScroll'
```

## License

FWShadowableScroll is available under the MIT license. See the LICENSE file for more info.
