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

@interface AAViewController ()

@property (nonatomic, strong) AAMultiSelectViewController* multiSelectVC;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation AAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonTapped:(id)sender
{
    self.multiSelectVC = [[AAMultiSelectViewController alloc] init];
    self.multiSelectVC.titleText = @"选择语言";
    self.multiSelectVC.view.frame =
    CGRectMake(0, 0, CGRectGetWidth(self.view.frame) * multiSelectViewWidthRatio, multiSelectViewHeight);
    self.multiSelectVC.dataArray = [self.dataArray copy];
//    @WeakObj(self);
    [self.multiSelectVC setConfirmBlock:^() {
//        for (YCSMultiSelectModel *selectModel in weakself.multiSelectVC.dataArray) {
//            selectModel.isSelected ?
//            [weakself.supplierProcess.supplier enablePaymentMethodType:selectModel.multiSelectId] :
//            [weakself.supplierProcess.supplier disablePaymentMethodType:selectModel.multiSelectId];
//        }
//        [weakself.supplierProcess.supplier updatePaymentTypeStr];
//        [weakself supplierDidChange];
    }];
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
