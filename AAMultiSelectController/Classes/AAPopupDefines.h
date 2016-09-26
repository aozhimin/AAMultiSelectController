//
//  AAPopupDefines.h
//  Pods
//
//  Created by dev-aozhimin on 16/9/26.
//
//

#ifndef AAPopupDefines_h
#define AAPopupDefines_h

// AAPopupViewShowType: Controls how the popup will be presented.
typedef NS_ENUM(NSInteger, AAPopupViewShowType) {
    AAPopupViewShowTypeNone = 0,
    AAPopupViewShowTypeFadeIn,
    AAPopupViewShowTypeGrowIn,
    AAPopupViewShowTypeShrinkIn,
    AAPopupViewShowTypeSlideInFromTop,
    AAPopupViewShowTypeSlideInFromBottom,
    AAPopupViewShowTypeSlideInFromLeft,
    AAPopupViewShowTypeSlideInFromRight,
    AAPopupViewShowTypeBounceIn,
    AAPopupViewShowTypeBounceInFromTop,
    AAPopupViewShowTypeBounceInFromBottom,
    AAPopupViewShowTypeBounceInFromLeft,
    AAPopupViewShowTypeBounceInFromRight,
};

// AAPopupViewDismissType: Controls how the popup will be dismissed.
typedef NS_ENUM(NSInteger, AAPopupViewDismissType) {
    AAPopupViewDismissTypeNone = 0,
    AAPopupViewDismissTypeFadeOut,
    AAPopupViewDismissTypeGrowOut,
    AAPopupViewDismissTypeShrinkOut,
    AAPopupViewDismissTypeSlideOutToTop,
    AAPopupViewDismissTypeSlideOutToBottom,
    AAPopupViewDismissTypeSlideOutToLeft,
    AAPopupViewDismissTypeSlideOutToRight,
    AAPopupViewDismissTypeBounceOut,
    AAPopupViewDismissTypeBounceOutToTop,
    AAPopupViewDismissTypeBounceOutToBottom,
    AAPopupViewDismissTypeBounceOutToLeft,
    AAPopupViewDismissTypeBounceOutToRight,
};

// AAPopupViewHorizontalLayout: Controls where the popup will come to rest horizontally.
typedef NS_ENUM(NSInteger, AAPopupViewHorizontalLayout) {
    AAPopupViewHorizontalLayoutCustom = 0,
    AAPopupViewHorizontalLayoutLeft,
    AAPopupViewHorizontalLayoutLeftOfCenter,
    AAPopupViewHorizontalLayoutCenter,
    AAPopupViewHorizontalLayoutRightOfCenter,
    AAPopupViewHorizontalLayoutRight,
};

// AAPopupViewVerticalLayout: Controls where the popup will come to rest vertically.
typedef NS_ENUM(NSInteger, AAPopupViewVerticalLayout) {
    AAPopupViewVerticalLayoutCustom = 0,
    AAPopupViewVerticalLayoutTop,
    AAPopupViewVerticalLayoutAboveCenter,
    AAPopupViewVerticalLayoutCenter,
    AAPopupViewVerticalLayoutBelowCenter,
    AAPopupViewVerticalLayoutBottom,
};

// AAPopupViewMaskType
typedef NS_ENUM(NSInteger, AAPopupViewMaskType) {
    AAPopupViewMaskTypeNone = 0, // Allow interaction with underlying views.
    AAPopupViewMaskTypeClear, // Don't allow interaction with underlying views.
    AAPopupViewMaskTypeDimmed, // Don't allow interaction with underlying views, dim background.
};

#endif /* AAPopupDefines_h */
