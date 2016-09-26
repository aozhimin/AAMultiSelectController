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

/**
 *  a callback when tap confirm button, selectedObjects is array of selected AAMultiSelectModel.
 */
@property (nonatomic, copy) void (^confirmBlock)(NSArray *selectedObjects);

- (void)show;

@end



