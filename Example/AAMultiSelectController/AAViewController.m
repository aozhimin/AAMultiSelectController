//
//  AAViewController.m
//  AAMultiSelectController
//
//  Created by dev-aozhimin on 09/23/2016.
//  Copyright (c) 2016 dev-aozhimin. All rights reserved.
//

#import "AAMultiSelectViewController.h"
#import "AAPopupView.h"
#import "AAViewController.h"
#import "AAMultiSelectModel.h"

static CGFloat const multiSelectViewHeight     = 250.f;
static CGFloat const multiSelectViewWidthRatio = 0.8f;

typedef NS_ENUM(NSUInteger, AATableViewCellType) {
    AATableViewCellTypeNone = 0,
    AATableViewCellTypeFadeIn,
    AATableViewCellTypeGrowIn,
    AATableViewCellTypeShrinkIn,
    AATableViewCellTypeSlideInFromTop,
    AATableViewCellTypeSlideInFromBottom,
    AATableViewCellTypeSlideInFromLeft,
    AATableViewCellTypeSlideInFromRight,
    AATableViewCellTypeBounceIn,
    AATableViewCellTypeBounceInFromTop,
    AATableViewCellTypeBounceInFromBottom,
    AATableViewCellTypeBounceInFromLeft,
    AATableViewCellTypeBounceInFromRight,
};


static NSString *const AATableViewCellTypeDescriptions [] = {
    [AATableViewCellTypeNone]               = @"None",
    [AATableViewCellTypeFadeIn]             = @"FadeIn",
    [AATableViewCellTypeGrowIn]             = @"GrowIn",
    [AATableViewCellTypeShrinkIn]           = @"ShrinkIn",
    [AATableViewCellTypeSlideInFromTop]     = @"SlideInFromTop",
    [AATableViewCellTypeSlideInFromBottom]  = @"SlideInFromBottom",
    [AATableViewCellTypeSlideInFromLeft]    = @"SlideInFromLeft",
    [AATableViewCellTypeSlideInFromRight]   = @"SlideInFromRight",
    [AATableViewCellTypeBounceIn]           = @"BounceIn",
    [AATableViewCellTypeBounceInFromTop]    = @"BounceInFromTop",
    [AATableViewCellTypeBounceInFromBottom] = @"BounceInFromBottom",
    [AATableViewCellTypeBounceInFromLeft]   = @"BounceInFromLeft",
    [AATableViewCellTypeBounceInFromRight]  = @"BounceInFromRight",


};

@interface AAViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) AAMultiSelectViewController *multiSelectVC;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation AAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - UITableView DataSource && Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sizeof(AATableViewCellTypeDescriptions) / sizeof(AATableViewCellTypeDescriptions[0]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"tableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier
                                                            forIndexPath:indexPath];
    cell.textLabel.text = AATableViewCellTypeDescriptions[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        NSArray *tmpArray = @[@"Objective-C", @"Swift", @"Java", @"Python",
                              @"PHP", @"Ruby", @"JavaScript", @"Go", @"Erlang",
                              @"C", @"C++", @"C#"];
        [tmpArray enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            AAMultiSelectModel *model = [AAMultiSelectModel new];
            model.title = title;
            model.multiSelectId = idx;
            [mutableArray addObject:model];
        }];
        _dataArray = [mutableArray copy];
    }
    return _dataArray;
}
@end
