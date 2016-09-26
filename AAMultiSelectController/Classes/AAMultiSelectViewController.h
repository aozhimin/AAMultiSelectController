//
//  AAMultiSelectViewController.h
//  Pods
//
//  Created by dev-aozhimin on 16/9/23.
//
//

#import <UIKit/UIKit.h>
#import "AAPopupDefines.h"

@interface AAMultiSelectViewController : UIViewController

/**
 *  data array to choose
 */
@property (nonatomic, strong) NSArray                *dataArray;

/**
 *  top title text
 */
@property (nonatomic, copy  ) NSString               *titleText;

/**
 *  top title text color
 */
@property (nonatomic, strong) UIColor                *titleTextColor;

/**
 *  top title font
 */
@property (nonatomic, strong) UIFont                 *titleFont;

/**
 *  confirm button background color
 */
@property (nonatomic, strong) UIColor                *confirmButtonBackgroudColor;

/**
 *  confirm button title color
 */
@property (nonatomic, strong) UIColor                *confirmButtonTitleColor;

/**
 *  confirm button title font
 */
@property (nonatomic, strong) UIFont                 *confirmButtonTitleFont;

/**
 *  cancel button background color
 */
@property (nonatomic, strong) UIColor                *cancelButtonBackgroudColor;

/**
 *  cancel button title color
 */
@property (nonatomic, strong) UIColor                *cancelButtonTitleColor;

/**
 *  cancel button title font
 */
@property (nonatomic, strong) UIFont                 *cancelButtonTitleFont;

/**
 *  item title color
 */
@property (nonatomic, strong) UIColor                *itemTitleColor;

/**
 *  item title font
 */
@property (nonatomic, strong) UIFont                 *itemTitleFont;

/**
 *  popup view show type, default by AAPopupViewShowTypeFadeIn
 */
@property (nonatomic, assign) AAPopupViewShowType    popupShowType;

/**
 *  popup view dismiss type, default by AAPopupViewDismissTypeFadeOut
 */
@property (nonatomic, assign) AAPopupViewDismissType popupDismissType;

/**
 *  popup view mask type, default by AAPopupViewMaskTypeDimmed
 */
@property (nonatomic, assign) AAPopupViewMaskType    popupMaskType;

/**
 *  should dismiss when background touch, default by Yes
 */
@property (nonatomic, assign) BOOL                   dismissOnBackgroundTouch;

/**
 *  a callback when tap confirm button, selectedObjects is array of selected AAMultiSelectModel.
 */
@property (nonatomic, copy) void (^confirmBlock)(NSArray *selectedObjects);


/**
 *  popup view show
 */
- (void)show;

@end



