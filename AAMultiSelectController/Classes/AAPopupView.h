//
//  AAPopupView.h
//  Pods
//
//  Created by dev-aozhimin on 16/9/23.
//
//

#import <UIKit/UIKit.h>
#import "AAPopupDefines.h"

// AAPopupViewLayout structure and maker functions
struct AAPopupViewLayout {
    AAPopupViewHorizontalLayout horizontal;
    AAPopupViewVerticalLayout vertical;
};
typedef struct AAPopupViewLayout AAPopupViewLayout;

extern AAPopupViewLayout AAPopupViewLayoutMake(AAPopupViewHorizontalLayout horizontal, AAPopupViewVerticalLayout vertical);

extern const AAPopupViewLayout AAPopupViewLayoutCenter;



@interface AAPopupView : UIView

// This is the view that you want to appear in Popup.
// - Must provide contentView before or in willStartShowing.
// - Must set desired size of contentView before or in willStartShowing.
@property (nonatomic, strong) UIView* contentView;

// Animation transition for presenting contentView. default = shrink in
@property (nonatomic, assign) AAPopupViewShowType showType;

// Animation transition for dismissing contentView. default = shrink out
@property (nonatomic, assign) AAPopupViewDismissType dismissType;

// Mask prevents background touches from passing to underlying views. default = dimmed.
@property (nonatomic, assign) AAPopupViewMaskType maskType;

// Overrides alpha value for dimmed background mask. default = 0.5
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;

// If YES, then popup will get dismissed when background is touched. default = YES.
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

// If YES, then popup will get dismissed when content view is touched. default = NO.
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;

// Block gets called before show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^willStartShowingCompletion)();

// Block gets called after show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishShowingCompletion)();

// Block gets called when dismiss animation starts. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^willStartDismissingCompletion)();

// Block gets called after dismiss animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishDismissingCompletion)();


/**
 *  Convenience method for creating popup with default values (mimics UIAlertView).
 *
 *  @param contentView popup content View
 *
 *  @return popup View
 */
+ (AAPopupView *)popupWithContentView:(UIView *)contentView;

/**
 *  Convenience method for creating popup with custom values.
 *
 *  @param contentView                    popup content View
 *  @param showType                       popup show Type
 *  @param dismissType                    popup dismiss Type
 *  @param maskType                       popup mask Type
 *  @param shouldDismissOnBackgroundTouch popup should or not dismiss when background touched
 *
 *  @return popup view
 */
+ (AAPopupView *)popupWithContentView:(UIView *)contentView
                             showType:(AAPopupViewShowType)showType
                          dismissType:(AAPopupViewDismissType)dismissType
                             maskType:(AAPopupViewMaskType)maskType
             dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch;

/**
 *  Convenience method for creating popup with custom values.
 *
 *  @param contentView                    popup content View
 *  @param showType                       popup show Type
 *  @param dismissType                    popup dismiss Type
 *  @param maskType                       popup mask Type
 *  @param shouldDismissOnBackgroundTouch popup should or not dismiss when background touched
 *  @param shouldDismissOnContentTouch    popup should or not dismiss when content view touched
 *
 *  @return popup view
 */
+ (AAPopupView *)popupWithContentView:(UIView *)contentView
                             showType:(AAPopupViewShowType)showType
                          dismissType:(AAPopupViewDismissType)dismissType
                             maskType:(AAPopupViewMaskType)maskType
             dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
                dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

/**
 *  Dismisses all the popups in the app. Use as a fail-safe for cleaning up.
 */
+ (void)dismissAllPopups;

/**
 *  Show popup with center layout. Animation determined by showType.
 */
- (void)show;

/**
 *  Show popup view
 *
 *  @param layout popup view show layout
 */
- (void)showWithLayout:(AAPopupViewLayout)layout;

/**
 *  Show and then dismiss after duration. 0.0 or less will be considered infinity.
 *
 *  @param duration popup view will dismiss after this duration
 */
- (void)showWithDuration:(NSTimeInterval)duration;

/**
 *  Show with layout and dismiss after duration.
 *
 *  @param layout   popup layout
 *  @param duration popup view will dismiss after this duration
 */
- (void)showWithLayout:(AAPopupViewLayout)layout duration:(NSTimeInterval)duration;

/**
 *  Show centered at point in view's coordinate system. If view is nil use screen base coordinates.
 *
 *  @param center popup show center point
 *  @param view   popup show in this view
 */
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view;

/**
 *  Show centered at point in view's coordinate system, then dismiss after duration.
 *
 *  @param center   popup show center point
 *  @param view     popup show in this view
 *  @param duration popup view will dismiss after this duration
 */
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration;

/**
 *  Dismiss popup. Uses dismissType if animated is YES.
 *
 *  @param animated is animated
 */
- (void)dismiss:(BOOL)animated;


#pragma mark Subclassing
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) BOOL isBeingShown;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) BOOL isBeingDismissed;

- (void)willStartShowing;
- (void)didFinishShowing;
- (void)willStartDismissing;
- (void)didFinishDismissing;

@end


#pragma mark - UIView Category
@interface UIView(AAPopupView)
- (void)forEachPopupDoBlock:(void (^)(AAPopupView *popup))block;
- (void)dismissPresentingPopup;

@end

