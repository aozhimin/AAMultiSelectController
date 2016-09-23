//
//  AAMultiSelectViewController.h
//  Pods
//
//  Created by dev-aozhimin on 16/9/23.
//
//

#import <UIKit/UIKit.h>

@interface AAMultiSelectViewController : UIViewController

@property (nonatomic, strong) NSArray  *dataArray;
@property (nonatomic, copy  ) NSString *titleText;
@property (nonatomic, copy) void (^confirmBlock)();

- (void)show;

@end



