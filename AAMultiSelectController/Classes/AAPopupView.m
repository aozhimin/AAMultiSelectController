//
//  AAPopupView.m
//  Pods
//
//  Created by dev-aozhimin on 16/9/23.
//
//

#import "AAPopupView.h"

typedef void (^AAPopupViewCompletionBlock)(BOOL finished);

static NSInteger const kAnimationOptionCurveIOS7 = (7 << 16);

AAPopupViewLayout AAPopupViewLayoutMake(AAPopupViewHorizontalLayout horizontal, AAPopupViewVerticalLayout vertical) {
    AAPopupViewLayout layout;
    layout.horizontal = horizontal;
    layout.vertical   = vertical;
    return layout;
}

const AAPopupViewLayout AAPopupViewLayoutCenter = { AAPopupViewHorizontalLayoutCenter, AAPopupViewVerticalLayoutCenter };


@interface NSValue (AAPopupViewLayout)

+ (NSValue *)valueWithAAPopupLayout:(AAPopupViewLayout)layout;
- (AAPopupViewLayout)AAPopupLayoutValue;

@end

static NSTimeInterval const kDefaultAnimationDuration        = 0.15;
static NSTimeInterval const kFadeAnimationDuration           = 0.15;
static NSTimeInterval const kGrowAnimationDuration           = 0.15;
static NSTimeInterval const kShrinkAnimationDuration         = 0.3;
static NSTimeInterval const kSlideAnimationDuration          = 0.3;
static NSTimeInterval const kBounceAnimationShowDuration     = 0.6;
static NSTimeInterval const kBounceAnimationDismiss1Duration = 0.13;
static NSTimeInterval const kBounceAnimationDismiss2Duration = kBounceAnimationDismiss1Duration * 2.0;

static CGFloat const kBounceAnimationSpringDamping      = 0.8f;
static CGFloat const kBounceAnimationSpringVelocity     = 15.0f;
static CGFloat const kBounceFromAnimationSpringVelocity = 10.0f;
static CGFloat const kDimmedMaskAlphaDefault            = 0.5f;
static CGFloat const kRatioSmall                        = 2.0f;
static CGFloat const kRatioMedium                       = 3.0f;
static CGFloat const kOffset                            = 40.0f;
static CGFloat const kTransformScaleVerySmall           = 0.1f;
static CGFloat const kTransformScaleRegular             = 0.8f;
static CGFloat const kTransformScaleMedium              = 0.85f;
static CGFloat const kTransformScaleLarge               = 1.1f;
static CGFloat const kTransformScaleVeryLarge           = 1.25f;

static NSString *const kDurationKey = @"duration";
static NSString *const kLayoutKey   = @"layout";
static NSString *const kCenterKey   = @"center";
static NSString *const kViewKey     = @"view";


@interface AAPopupView () {
    // views
    UIView *_backgroundView;
    UIView *_containerView;
    
    // state flags
    BOOL _isBeingShown;
    BOOL _isShowing;
    BOOL _isBeingDismissed;
}

- (void)updateForInterfaceOrientation;
- (void)didChangeStatusBarOrientation:(NSNotification *)notification;

// Used for calling dismiss:YES from selector because you can't pass primitives, thanks objc
- (void)dismiss;

@end


@implementation AAPopupView

@synthesize backgroundView   = _backgroundView;
@synthesize containerView    = _containerView;
@synthesize isBeingShown     = _isBeingShown;
@synthesize isShowing        = _isShowing;
@synthesize isBeingDismissed = _isBeingDismissed;


- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    // stop listening to notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)init {
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        self.shouldDismissOnBackgroundTouch = YES;
        self.shouldDismissOnContentTouch = NO;
        
        self.showType = AAPopupViewShowTypeShrinkIn;
        self.dismissType = AAPopupViewDismissTypeShrinkOut;
        self.maskType = AAPopupViewMaskTypeDimmed;
        self.dimmedMaskAlpha = kDimmedMaskAlphaDefault;
        
        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = NO;
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.frame = self.bounds;
        
        _containerView = [[UIView alloc] init];
        _containerView.autoresizesSubviews = NO;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_backgroundView];
        [self addSubview:_containerView];
        
        // register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarOrientation:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        // Try to dismiss if backgroundTouch flag set.
        if (_shouldDismissOnBackgroundTouch) {
            [self dismiss:YES];
        }
        // If no mask, then return nil so touch passes through to underlying views.
        if (_maskType == AAPopupViewMaskTypeNone) {
            return nil;
        } else {
            return hitView;
        }
    } else {
        // If view is within containerView and contentTouch flag set, then try to hide.
        if ([hitView isDescendantOfView:_containerView]) {
            if (_shouldDismissOnContentTouch) {
                [self dismiss:YES];
            }
        }
        return hitView;
    }
}


#pragma mark - Class Public

+ (AAPopupView *)popupWithContentView:(UIView*)contentView {
    AAPopupView *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    return popup;
}

+ (AAPopupView *)popupWithContentView:(UIView *)contentView
                             showType:(AAPopupViewShowType)showType
                          dismissType:(AAPopupViewDismissType)dismissType
                             maskType:(AAPopupViewMaskType)maskType
             dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch {
    return [AAPopupView popupWithContentView:contentView
                                    showType:showType
                                 dismissType:dismissType
                                    maskType:maskType
                    dismissOnBackgroundTouch:shouldDismissOnBackgroundTouch
                       dismissOnContentTouch:NO];
}


+ (AAPopupView *)popupWithContentView:(UIView *)contentView
                             showType:(AAPopupViewShowType)showType
                          dismissType:(AAPopupViewDismissType)dismissType
                             maskType:(AAPopupViewMaskType)maskType
             dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
                dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch {
    AAPopupView *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    popup.showType = showType;
    popup.dismissType = dismissType;
    popup.maskType = maskType;
    popup.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch;
    popup.shouldDismissOnContentTouch = shouldDismissOnContentTouch;
    return popup;
}


+ (void)dismissAllPopups {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        [window forEachPopupDoBlock:^(AAPopupView *popup) {
            [popup dismiss:NO];
        }];
    }
}


#pragma mark - Public

- (void)show {
    [self showWithLayout:AAPopupViewLayoutCenter];
}


- (void)showWithLayout:(AAPopupViewLayout)layout {
    [self showWithLayout:layout duration:0.0];
}


- (void)showWithDuration:(NSTimeInterval)duration {
    [self showWithLayout:AAPopupViewLayoutCenter duration:duration];
}


- (void)showWithLayout:(AAPopupViewLayout)layout
              duration:(NSTimeInterval)duration {
    NSDictionary *parameters = @{kLayoutKey   : [NSValue valueWithAAPopupLayout:layout],
                                 kDurationKey : @(duration)};
    [self showWithParameters:parameters];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView *)view {
    [self showAtCenter:center inView:view withDuration:0.0];
}


- (void)showAtCenter:(CGPoint)center
              inView:(UIView *)view
        withDuration:(NSTimeInterval)duration {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSValue valueWithCGPoint:center] forKey:kCenterKey];
    [parameters setValue:@(duration) forKey:kDurationKey];
    [parameters setValue:view forKey:kViewKey];
    [self showWithParameters:[NSDictionary dictionaryWithDictionary:parameters]];
}


- (void)dismiss:(BOOL)animated {
    if (_isShowing && !_isBeingDismissed) {
        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = YES;
        
        // cancel previous dismiss requests (i.e. the dismiss after duration call).
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
        [self willStartDismissing];
        if (self.willStartDismissingCompletion != nil) {
            self.willStartDismissingCompletion();
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            
            // Animate background if needed
            void (^backgroundAnimationBlock)(void) = ^(void) {
                _backgroundView.alpha = 0.0;
            };
            if (animated && (_showType != AAPopupViewShowTypeNone)) {
                // Make fade happen faster than motion. Use linear for fades.
                [UIView animateWithDuration:kDefaultAnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:backgroundAnimationBlock
                                 completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            // Setup completion block
            AAPopupViewCompletionBlock completionBlock = ^(BOOL finished) {
                [self removeFromSuperview];
                _isBeingShown = NO;
                _isShowing = NO;
                _isBeingDismissed = NO;
                [self didFinishDismissing];
                if (self.didFinishDismissingCompletion != nil) {
                    self.didFinishDismissingCompletion();
                }
            };
            
            // Animate content if needed
            if (animated) {
                [self dismissWithCompletionBlock:completionBlock];
            } else {
                self.containerView.alpha = 0.0;
                completionBlock(YES);
            }
        });
    }
}


#pragma mark - Private

- (void)showWithParameters:(NSDictionary *)parameters {
    // If popup can be shown
    if (!_isBeingShown && !_isShowing && !_isBeingDismissed) {
        _isBeingShown = YES;
        _isShowing = NO;
        _isBeingDismissed = NO;
        [self willStartShowing];
        if (self.willStartShowingCompletion) {
            self.willStartShowingCompletion();
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            
            // Prepare by adding to the top window.
            if(!self.superview){
                NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
                
                for (UIWindow *window in frontToBackWindows) {
                    if (window.windowLevel == UIWindowLevelNormal) {
                        [window addSubview:self];
                        break;
                    }
                }
            }
            
            // Before we calculate layout for containerView, make sure we are transformed for current orientation.
            [self updateForInterfaceOrientation];
            
            // Make sure we're not hidden
            self.hidden = NO;
            self.alpha = 1.0;
            
            // Setup background view
            _backgroundView.alpha = 0.0;
            if (_maskType == AAPopupViewMaskTypeDimmed) {
                _backgroundView.backgroundColor = [UIColor colorWithRed:(0.0/255.0f)
                                                                  green:(0.0/255.0f)
                                                                   blue:(0.0/255.0f)
                                                                  alpha:self.dimmedMaskAlpha];
            } else {
                _backgroundView.backgroundColor = [UIColor clearColor];
            }
            
            // Animate background if needed
            void (^backgroundAnimationBlock)(void) = ^(void) {
                _backgroundView.alpha = 1.0;
            };
            
            if (_showType != AAPopupViewShowTypeNone) {
                // Make fade happen faster than motion. Use linear for fades.
                [UIView animateWithDuration:kDefaultAnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:backgroundAnimationBlock
                                 completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            // Determine duration. Default to 0 if none provided.
            NSTimeInterval duration;
            NSNumber *durationNumber = [parameters valueForKey:kDurationKey];
            if (durationNumber != nil) {
                duration = [durationNumber doubleValue];
            } else {
                duration = 0.0;
            }
            
            // Setup completion block
            AAPopupViewCompletionBlock completionBlock = ^(BOOL finished) {
                _isBeingShown = NO;
                _isShowing = YES;
                _isBeingDismissed = NO;
                [self didFinishShowing];
                if (self.didFinishShowingCompletion != nil) {
                    self.didFinishShowingCompletion();
                }
                
                // Set to hide after duration if greater than zero.
                if (duration > 0.0) {
                    [self performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
                }
            };
            
            // Add contentView to container
            if (self.contentView.superview != _containerView) {
                [_containerView addSubview:self.contentView];
            }
            
            // Re-layout (this is needed if the contentView is using autoLayout)
            [self.contentView layoutIfNeeded];
            
            // Size container to match contentView
            CGRect containerFrame = _containerView.frame;
            containerFrame.size = self.contentView.frame.size;
            _containerView.frame = containerFrame;
            // Position contentView to fill it
            CGRect contentViewFrame = self.contentView.frame;
            contentViewFrame.origin = CGPointZero;
            self.contentView.frame = contentViewFrame;
            
            // Reset _containerView's constraints in case contentView is uaing autolayout.
            UIView *contentView = _contentView;
            NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
            
            [_containerView removeConstraints:_containerView.constraints];
            [_containerView addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:nil
                                                       views:views]];
            
            [_containerView addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:nil
                                                       views:views]];
            
            // Determine final position and necessary autoresizingMask for container.
            CGRect finalContainerFrame = containerFrame;
            UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;
            
            // Use explicit center coordinates if provided.
            NSValue *centerValue = [parameters valueForKey:kCenterKey];
            if (centerValue != nil) {
                
                CGPoint centerInView = [centerValue CGPointValue];
                CGPoint centerInSelf;
                
                // Convert coordinates from provided view to self. Otherwise use as-is.
                UIView *fromView = [parameters valueForKey:kViewKey];
                if (fromView != nil) {
                    centerInSelf = [self convertPoint:centerInView fromView:fromView];
                } else {
                    centerInSelf = centerInView;
                }
                
                finalContainerFrame.origin.x = (centerInSelf.x - CGRectGetWidth(finalContainerFrame) / kRatioSmall);
                finalContainerFrame.origin.y = (centerInSelf.y - CGRectGetHeight(finalContainerFrame) / kRatioSmall);
                containerAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
            }
            
            // Otherwise use relative layout. Default to center if none provided.
            else {
                NSValue *layoutValue = [parameters valueForKey:kLayoutKey];
                AAPopupViewLayout layout;
                if (layoutValue != nil) {
                    layout = [layoutValue AAPopupLayoutValue];
                } else {
                    layout = AAPopupViewLayoutCenter;
                }
                finalContainerFrame = [self getContainerFrameWithLayout:layout
                                                         containerFrame:finalContainerFrame
                                              containerAutoresizingMask:containerAutoresizingMask];
            }
            
            _containerView.autoresizingMask = containerAutoresizingMask;
            
            // Animate content if needed
            [self displayWithShowType:_showType inContainerFrame:finalContainerFrame compltionBlock:completionBlock];
        });
    }
}

- (CGRect)getContainerFrameWithLayout:(AAPopupViewLayout)layout
                       containerFrame:(CGRect)containerFrame
            containerAutoresizingMask:(UIViewAutoresizing)containerAutoresizingMask {
    switch (layout.horizontal) {
            case AAPopupViewHorizontalLayoutLeft:{
                containerFrame.origin.x = 0.0;
                containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
                break;
            }
            
            case AAPopupViewHorizontalLayoutLeftOfCenter:{
                containerFrame.origin.x = floorf(CGRectGetWidth(self.bounds) / kRatioMedium -
                                                 CGRectGetWidth(containerFrame) / kRatioSmall);
                containerAutoresizingMask = containerAutoresizingMask |
                UIViewAutoresizingFlexibleLeftMargin |
                UIViewAutoresizingFlexibleRightMargin;
                break;
            }
            
            case AAPopupViewHorizontalLayoutCenter:{
                containerFrame.origin.x = floorf((CGRectGetWidth(self.bounds) -
                                                  CGRectGetWidth(containerFrame)) / kRatioSmall);
                containerAutoresizingMask = containerAutoresizingMask |
                UIViewAutoresizingFlexibleLeftMargin |
                UIViewAutoresizingFlexibleRightMargin;
                break;
            }
            
            case AAPopupViewHorizontalLayoutRightOfCenter:{
                containerFrame.origin.x = floorf(CGRectGetWidth(self.bounds) * kRatioSmall / kRatioMedium -
                                                 CGRectGetWidth(containerFrame) / kRatioSmall);
                containerAutoresizingMask = containerAutoresizingMask |
                UIViewAutoresizingFlexibleLeftMargin |
                UIViewAutoresizingFlexibleRightMargin;
                break;
            }
            
            case AAPopupViewHorizontalLayoutRight:{
                containerFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame);
                containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
                break;
            }
            
        default:
            break;
    }
    
    // Vertical
    switch (layout.vertical) {
            case AAPopupViewVerticalLayoutTop:{
                containerFrame.origin.y = 0;
                containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
                break;
            }
            
            case AAPopupViewVerticalLayoutAboveCenter:{
                containerFrame.origin.y = floorf(CGRectGetHeight(self.bounds) / kRatioMedium -
                                                 CGRectGetHeight(containerFrame) / kRatioSmall);
                containerAutoresizingMask = containerAutoresizingMask |
                UIViewAutoresizingFlexibleTopMargin |
                UIViewAutoresizingFlexibleBottomMargin;
                break;
            }
            
            case AAPopupViewVerticalLayoutCenter:{
                containerFrame.origin.y = floorf((CGRectGetHeight(self.bounds) -
                                                  CGRectGetHeight(containerFrame)) / kRatioSmall);
                containerAutoresizingMask = containerAutoresizingMask |
                UIViewAutoresizingFlexibleTopMargin |
                UIViewAutoresizingFlexibleBottomMargin;
                break;
            }
            
            case AAPopupViewVerticalLayoutBelowCenter:{
                containerFrame.origin.y = floorf(CGRectGetHeight(self.bounds) * kRatioSmall / kRatioMedium -
                                                 CGRectGetHeight(containerFrame) / kRatioSmall);
                containerAutoresizingMask = containerAutoresizingMask |
                UIViewAutoresizingFlexibleTopMargin |
                UIViewAutoresizingFlexibleBottomMargin;
                break;
            }
            
            case AAPopupViewVerticalLayoutBottom:{
                containerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame);
                containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
                break;
            }
        default:
            break;
    }
    return containerFrame;
}

- (void)displayWithShowType:(AAPopupViewShowType)showType
           inContainerFrame:(CGRect)finalContainerFrame
             compltionBlock:(AAPopupViewCompletionBlock)completionBlock {
    switch (_showType) {
            case AAPopupViewShowTypeFadeIn:{
                _containerView.alpha = 0.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kFadeAnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     _containerView.alpha = 1.0;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeGrowIn:{
                
                _containerView.alpha = 0.0;
                // set frame before transform here...
                CGRect startFrame = finalContainerFrame;
                _containerView.frame = startFrame;
                _containerView.transform = CGAffineTransformMakeScale(kTransformScaleMedium, kTransformScaleMedium);
                
                [UIView animateWithDuration:kGrowAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.alpha = 1.0;
                                     // set transform before frame here...
                                     _containerView.transform = CGAffineTransformIdentity;
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeShrinkIn:{
                _containerView.alpha = 0.0;
                // set frame before transform here...
                CGRect startFrame = finalContainerFrame;
                _containerView.frame = startFrame;
                _containerView.transform = CGAffineTransformMakeScale(kTransformScaleVeryLarge, kTransformScaleVeryLarge);
                
                [UIView animateWithDuration:kShrinkAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.alpha = 1.0;
                                     // set transform before frame here...
                                     _containerView.transform = CGAffineTransformIdentity;
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeSlideInFromTop:{
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kSlideAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeSlideInFromBottom:{
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.y = CGRectGetHeight(self.bounds);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kSlideAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeSlideInFromLeft:{
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.x = - CGRectGetWidth(finalContainerFrame);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kSlideAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeSlideInFromRight:{
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.x = CGRectGetWidth(self.bounds);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kSlideAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeBounceIn:{
                _containerView.alpha = 0.0;
                // set frame before transform here...
                CGRect startFrame = finalContainerFrame;
                _containerView.frame = startFrame;
                _containerView.transform = CGAffineTransformMakeScale(kTransformScaleVerySmall, kTransformScaleVerySmall);
                
                [UIView animateWithDuration:kBounceAnimationShowDuration
                                      delay:0.0
                     usingSpringWithDamping:kBounceAnimationSpringDamping
                      initialSpringVelocity:kBounceAnimationSpringVelocity
                                    options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     _containerView.alpha = 1.0;
                                     _containerView.transform = CGAffineTransformIdentity;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeBounceInFromTop:{
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.y = - CGRectGetHeight(finalContainerFrame);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kBounceAnimationShowDuration
                                      delay:0.0
                     usingSpringWithDamping:kBounceAnimationSpringDamping
                      initialSpringVelocity:kBounceFromAnimationSpringVelocity
                                    options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeBounceInFromBottom:{
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.y = CGRectGetHeight(self.bounds);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kBounceAnimationShowDuration
                                      delay:0.0
                     usingSpringWithDamping:kBounceAnimationSpringDamping
                      initialSpringVelocity:kBounceFromAnimationSpringVelocity
                                    options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeBounceInFromLeft:{
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.x = - CGRectGetWidth(finalContainerFrame);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kBounceAnimationShowDuration
                                      delay:0.0
                     usingSpringWithDamping:kBounceAnimationSpringDamping
                      initialSpringVelocity:kBounceFromAnimationSpringVelocity
                                    options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            case AAPopupViewShowTypeBounceInFromRight: {
                _containerView.alpha = 1.0;
                _containerView.transform = CGAffineTransformIdentity;
                CGRect startFrame = finalContainerFrame;
                startFrame.origin.x = CGRectGetWidth(self.bounds);
                _containerView.frame = startFrame;
                
                [UIView animateWithDuration:kBounceAnimationShowDuration
                                      delay:0.0
                     usingSpringWithDamping:kBounceAnimationSpringDamping
                      initialSpringVelocity:kBounceFromAnimationSpringVelocity
                                    options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     _containerView.frame = finalContainerFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
        default:{
            self.containerView.alpha = 1.0;
            self.containerView.transform = CGAffineTransformIdentity;
            self.containerView.frame = finalContainerFrame;
            
            completionBlock(YES);
            
            break;
        }
    }
}

- (void)dismissWithCompletionBlock:(AAPopupViewCompletionBlock)completionBlock {
    switch (_dismissType) {
            case AAPopupViewDismissTypeFadeOut:{
                [UIView animateWithDuration:kFadeAnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     _containerView.alpha = 0.0;
                                 } completion:completionBlock];
                break;
            }
            
            case AAPopupViewDismissTypeGrowOut:{
                [UIView animateWithDuration:kGrowAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7
                                 animations:^{
                                     _containerView.alpha = 0.0;
                                     _containerView.transform = CGAffineTransformMakeScale(kTransformScaleVeryLarge, kTransformScaleVeryLarge);
                                 } completion:completionBlock];
                break;
            }
            
            case AAPopupViewDismissTypeShrinkOut:{
                [UIView animateWithDuration:kShrinkAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7
                                 animations:^{
                                     _containerView.alpha = 0.0;
                                     _containerView.transform = CGAffineTransformMakeScale(kTransformScaleRegular, kTransformScaleRegular);
                                 } completion:completionBlock];
                break;
            }
            
            case AAPopupViewDismissTypeSlideOutToTop:{
                [UIView animateWithDuration:kSlideAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7
                                 animations:^{
                                     CGRect finalFrame = _containerView.frame;
                                     finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                     _containerView.frame = finalFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            
            case AAPopupViewDismissTypeSlideOutToBottom:{
                [UIView animateWithDuration:kSlideAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7
                                 animations:^{
                                     CGRect finalFrame = _containerView.frame;
                                     finalFrame.origin.y = CGRectGetHeight(self.bounds);
                                     _containerView.frame = finalFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            
            case AAPopupViewDismissTypeSlideOutToLeft:{
                [UIView animateWithDuration:kSlideAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7
                                 animations:^{
                                     CGRect finalFrame = _containerView.frame;
                                     finalFrame.origin.x = - CGRectGetWidth(finalFrame);
                                     _containerView.frame = finalFrame;
                                 }
                                 completion:completionBlock];
                break;
            }
            
            case AAPopupViewDismissTypeSlideOutToRight:{
                [UIView animateWithDuration:kSlideAnimationDuration
                                      delay:0
                                    options:kAnimationOptionCurveIOS7
                                 animations:^{
                                     CGRect finalFrame = _containerView.frame;
                                     finalFrame.origin.x = CGRectGetWidth(self.bounds);
                                     _containerView.frame = finalFrame;
                                 }
                                 completion:completionBlock];
                
                break;
            }
            
            case AAPopupViewDismissTypeBounceOut:{
                [UIView animateWithDuration:kBounceAnimationDismiss1Duration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(void){
                                     _containerView.transform = CGAffineTransformMakeScale(kTransformScaleLarge, kTransformScaleLarge);
                                 }
                                 completion:^(BOOL finished){
                                     [UIView animateWithDuration:kBounceAnimationDismiss2Duration
                                                           delay:0
                                                         options:UIViewAnimationOptionCurveEaseIn
                                                      animations:^(void){
                                                          _containerView.alpha = 0.0;
                                                          _containerView.transform = CGAffineTransformMakeScale(kTransformScaleVerySmall, kTransformScaleVerySmall);
                                                      }
                                                      completion:completionBlock];
                                 }];
                break;
            }
            
            case AAPopupViewDismissTypeBounceOutToTop:{
                [UIView animateWithDuration:kBounceAnimationDismiss1Duration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(void){
                                     CGRect finalFrame = _containerView.frame;
                                     finalFrame.origin.y += kOffset;
                                     _containerView.frame = finalFrame;
                                 }
                                 completion:^(BOOL finished){
                                     [UIView animateWithDuration:kBounceAnimationDismiss2Duration
                                                           delay:0
                                                         options:UIViewAnimationOptionCurveEaseIn
                                                      animations:^(void){
                                                          CGRect finalFrame = _containerView.frame;
                                                          finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                                          _containerView.frame = finalFrame;
                                                      }
                                                      completion:completionBlock];
                                 }];
                
                break;
            }
            
            case AAPopupViewDismissTypeBounceOutToBottom:{
                [UIView animateWithDuration:kBounceAnimationDismiss1Duration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(void){
                                     CGRect finalFrame = _containerView.frame;
                                     finalFrame.origin.y -= kOffset;
                                     _containerView.frame = finalFrame;
                                 }
                                 completion:^(BOOL finished){
                                     [UIView animateWithDuration:kBounceAnimationDismiss2Duration
                                                           delay:0
                                                         options:UIViewAnimationOptionCurveEaseIn
                                                      animations:^(void){
                                                          CGRect finalFrame = _containerView.frame;
                                                          finalFrame.origin.y = CGRectGetHeight(self.bounds);
                                                          _containerView.frame = finalFrame;
                                                      }
                                                      completion:completionBlock];
                                 }];
                
                break;
            }
            
            case AAPopupViewDismissTypeBounceOutToLeft:{
                [UIView animateWithDuration:kBounceAnimationDismiss1Duration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(void){
                                     CGRect finalFrame = _containerView.frame;
                                     finalFrame.origin.x += kOffset;
                                     _containerView.frame = finalFrame;
                                 }
                                 completion:^(BOOL finished){
                                     [UIView animateWithDuration:kBounceAnimationDismiss2Duration
                                                           delay:0
                                                         options:UIViewAnimationOptionCurveEaseIn
                                                      animations:^(void){
                                                          CGRect finalFrame = _containerView.frame;
                                                          finalFrame.origin.x = - CGRectGetWidth(finalFrame);
                                                          _containerView.frame = finalFrame;
                                                      }
                                                      completion:completionBlock];
                                 }];
                break;
            }
            
            case AAPopupViewDismissTypeBounceOutToRight:{
                [UIView animateWithDuration:kBounceAnimationDismiss1Duration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(void){
                                     CGRect finalFrame = _containerView.frame;
                                     finalFrame.origin.x -= kOffset;
                                     _containerView.frame = finalFrame;
                                 }
                                 completion:^(BOOL finished){
                                     [UIView animateWithDuration:kBounceAnimationDismiss2Duration
                                                           delay:0
                                                         options:UIViewAnimationOptionCurveEaseIn
                                                      animations:^(void){
                                                          CGRect finalFrame = _containerView.frame;
                                                          finalFrame.origin.x = CGRectGetWidth(self.bounds);
                                                          _containerView.frame = finalFrame;
                                                      }
                                                      completion:completionBlock];
                                 }];
                break;
            }
            
        default:{
            self.containerView.alpha = 0.0;
            completionBlock(YES);
            break;
        }
    }
}

- (void)dismiss {
    [self dismiss:YES];
}


- (void)updateForInterfaceOrientation {
    
    // We must manually fix orientation prior to iOS 8
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        CGFloat angle;
        switch (orientation) {
                case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                break;
                case UIInterfaceOrientationLandscapeLeft:
                angle = - M_PI / 2.0f;;
                break;
                case UIInterfaceOrientationLandscapeRight:
                angle = M_PI / 2.0f;
                break;
            default: // as UIInterfaceOrientationPortrait
                angle = 0.0;
                break;
        }
        self.transform = CGAffineTransformMakeRotation(angle);
    }
    self.frame = self.window.bounds;
}


#pragma mark - Notification handlers

- (void)didChangeStatusBarOrientation:(NSNotification *)notification {
    [self updateForInterfaceOrientation];
}


#pragma mark - Subclassing

- (void)willStartShowing {
    
}

- (void)didFinishShowing {
    
}


- (void)willStartDismissing {
    
}

- (void)didFinishDismissing {
    
}

@end


#pragma mark - Categories

@implementation UIView(AAPopupView)

- (void)forEachPopupDoBlock:(void (^)(AAPopupView *popup))block {
    for (UIView *subview in self.subviews){
        if ([subview isKindOfClass:[AAPopupView class]]){
            block((AAPopupView *)subview);
        } else {
            [subview forEachPopupDoBlock:block];
        }
    }
}

- (void)dismissPresentingPopup {
    // Iterate over superviews until you find a AAPopupView and dismiss it, then gtfo
    UIView *view = self;
    while (view != nil) {
        if ([view isKindOfClass:[AAPopupView class]]) {
            [(AAPopupView *)view dismiss:YES];
            break;
        }
        view = [view superview];
    }
}

@end


@implementation NSValue (AAPopupViewLayout)

+ (NSValue *)valueWithAAPopupLayout:(AAPopupViewLayout)layout {
    return [NSValue valueWithBytes:&layout objCType:@encode(AAPopupViewLayout)];
}

- (AAPopupViewLayout)AAPopupLayoutValue {
    AAPopupViewLayout layout;
    [self getValue:&layout];
    return layout;
}

@end

