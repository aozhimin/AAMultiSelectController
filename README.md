# AAMultiSelectController

[![CI Status](http://img.shields.io/travis/dev-aozhimin/AAMultiSelectController.svg?style=flat)](https://travis-ci.org/dev-aozhimin/AAMultiSelectController)
[![Version](https://img.shields.io/cocoapods/v/AAMultiSelectController.svg?style=flat)](http://cocoapods.org/pods/AAMultiSelectController)
[![License](https://img.shields.io/cocoapods/l/AAMultiSelectController.svg?style=flat)](http://cocoapods.org/pods/AAMultiSelectController)
[![Platform](https://img.shields.io/cocoapods/p/AAMultiSelectController.svg?style=flat)](http://cocoapods.org/pods/AAMultiSelectController)

![logo](https://github.com/aozhimin/AAMultiSelectController/blob/master/images/demo.gif)

AAMultiSelectController provides a popup dialog which user can multi-select.it's easy to use and integrate in your project.

![Demo](https://github.com/aozhimin/AAMultiSelectController/blob/master/images/logo.png)

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
AAMultiSelectController works on iOS 8.0+ and requires ARC to build.


## Installation

AAMultiSelectController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AAMultiSelectController"
```

and edit pod file, install `AAMultiSelectController` into your project just excute command as follow:

```ruby
pod install
```

## Usage
(see the usage which I put in the example project)

```objective-c
@property (nonatomic, strong) AAMultiSelectViewController *multiSelectVC;


self.multiSelectVC = [[AAMultiSelectViewController alloc] init];    
self.multiSelectVC.titleText = @"选择语言";
self.multiSelectVC.view.frame = CGRectMake(0, 0,
                                               CGRectGetWidth(self.view.frame) * multiSelectViewWidthRatio,
                                               multiSelectViewHeight);
self.multiSelectVC.itemTitleColor = [UIColor redColor];
self.multiSelectVC.dataArray = [self.dataArray copy];
[self.multiSelectVC setConfirmBlock:^(NSArray *selectedObjects) {
        NSMutableString *message = [NSMutableString stringWithString:@"您选中了:"];
        [selectedObjects enumerateObjectsUsingBlock:^(AAMultiSelectModel * _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
            [message appendFormat:@"%@,", object.title];
        }];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[message copy]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
    }];
self.multiSelectVC.popupShowType = indexPath.row;
self.multiSelectVC.popupDismissType = indexPath.row;
[self.multiSelectVC show];
```


## Author

Alex Ao, aozhimin0811@gmail.com

## License

AAMultiSelectController is available under the MIT license. See the LICENSE file for more info.
