//
//  AAMultiSelectViewController.m
//  Pods
//
//  Created by dev-aozhimin on 16/9/23.
//
//

#import "AAMultiSelectViewController.h"
#import "AAPopupView.h"
#import "Masonry.h"
#import "AAMultiSelectTableViewCell.h"
#import "AAMultiSelectModel.h"
//#import <Masonry.h>

#define AA_SAFE_BLOCK_CALL(block, ...) block ? block(__VA_ARGS__) : nil
#define WeakObj(o) autoreleasepool{} __weak typeof(o) weak##o = o;
#define UIColorFromHexWithAlpha(hexValue,a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:a]
#define UIColorFromHex(hexValue) UIColorFromHexWithAlpha(hexValue,1.0)

#define FONT(size) [UIFont systemFontOfSize:size]
#define BOLD_FONT(size) [UIFont boldSystemFontOfSize:size]

static NSString * const tableViewCellNibName           = @"AAMultiSelectTableViewCell";
static NSString * const tableViewCellIdentifierName    = @"multiTableViewCell";

static CGFloat const viewCornerRadius                  = 5.f;
static CGFloat const tableViewRowHeight                = 50;
static NSInteger const titleLabelMarginTop             = 15;
static CGFloat const separatorHeight                   = 0.5f;
static NSInteger const topSeparatorMarginTop           = 10;
static NSInteger const bottomSeparatorMarginTop        = 10;


static NSInteger const buttonContainerViewMarginTop    = 25;
static NSInteger const buttonContainerViewMarginLeft   = 20;
static NSInteger const buttonContainerViewMarginRight  = 20;
static NSInteger const buttonContainerViewMarginBottom = 20;
static CGFloat const buttonCornerRadius                = 5.f;
static CGFloat const buttonTitleFontSize               = 16.0;
static CGFloat const buttonInsetsTop                   = 10.0;
static CGFloat const buttonInsetsLeft                  = 30.0;
static CGFloat const buttonInsetsBottom                = 10.0;
static CGFloat const buttonInsetsRight                 = 30.0;
static NSInteger const cancelButtonBackgroundColor     = 0XAAAAAA;
static NSInteger const separatorBackgroundColor        = 0XDCDCDC;



@interface AAMultiSelectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton    *confirmButton;
@property (nonatomic, strong) UIButton    *cancelButton;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UIView      *topSeparator;
@property (nonatomic, strong) UIView      *bottomSeparator;
@property (nonatomic, strong) AAPopupView *popupView;

@end

@implementation AAMultiSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    [self setupView];
    [self setupTitleLabel];
    [self setupTableView];
    [self setupButtons];
}

- (void)setupView {
    self.view.layer.cornerRadius = viewCornerRadius;
    self.view.clipsToBounds      = YES;
    self.view.backgroundColor    = [UIColor whiteColor];
}

- (void)setupTitleLabel {
    @WeakObj(self);
    UILabel *titleLabel               = [UILabel new];
    titleLabel.textColor              = [UIColor blackColor];
    titleLabel.font                   = [UIFont systemFontOfSize:15];
    titleLabel.text                   = self.titleText;
    titleLabel.textAlignment          = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view);
        make.right.equalTo(weakself.view);
        make.top.equalTo(weakself.view).offset(titleLabelMarginTop);
    }];
    self.titleLabel                   = titleLabel;
    self.topSeparator                 = [UIView new];
    self.topSeparator.backgroundColor = UIColorFromHex(separatorBackgroundColor);
    [self.view addSubview:self.topSeparator];
    [self.topSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view);
        make.right.equalTo(weakself.view);
        make.top.equalTo(weakself.titleLabel.mas_bottom).offset(topSeparatorMarginTop);
        make.height.mas_equalTo(separatorHeight);
    }];
}

- (void)setupButtons {
    @WeakObj(self);
    UIView *buttonContainerView           = [[UIView alloc] init];
    buttonContainerView.backgroundColor   = [UIColor clearColor];
    [self.view addSubview:buttonContainerView];
    [buttonContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).offset(buttonContainerViewMarginLeft);
        make.right.equalTo(weakself.view).offset(-buttonContainerViewMarginRight);
        make.bottom.equalTo(weakself.view).offset(-buttonContainerViewMarginBottom);
        make.top.equalTo(weakself.tableView.mas_bottom).offset(buttonContainerViewMarginTop);
    }];
    
    self.confirmButton                    = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.backgroundColor    = [UIColor greenColor];
    self.confirmButton.layer.cornerRadius = buttonCornerRadius;
    self.confirmButton.titleLabel.font    = BOLD_FONT(buttonTitleFontSize);
    self.confirmButton.contentEdgeInsets  = UIEdgeInsetsMake(buttonInsetsTop, buttonInsetsLeft,
                                                             buttonInsetsBottom, buttonInsetsRight);
    [self.confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [buttonContainerView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(buttonContainerView);
        make.top.equalTo(buttonContainerView);
        make.bottom.equalTo(buttonContainerView);
    }];
    
    self.cancelButton                     = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.backgroundColor     = UIColorFromHex(cancelButtonBackgroundColor);
    self.cancelButton.layer.cornerRadius  = buttonCornerRadius;
    self.cancelButton.titleLabel.font     = BOLD_FONT(buttonTitleFontSize);
    self.cancelButton.contentEdgeInsets   = UIEdgeInsetsMake(buttonInsetsTop, buttonInsetsLeft,
                                                             buttonInsetsBottom, buttonInsetsRight);
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [buttonContainerView addSubview:self.cancelButton];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(buttonContainerView);
        make.bottom.equalTo(buttonContainerView);
        make.top.equalTo(buttonContainerView);
        make.width.equalTo(weakself.confirmButton);
    }];
}

- (void)setupTableView {
    @WeakObj(self);
    UITableView *tableView       = [UITableView new];
    tableView.rowHeight          = tableViewRowHeight;
    tableView.tableFooterView    = [UIView new];
//    [tableView registerNib:[UINib nibWithNibName:tableViewCellNibName bundle:nil]
//    forCellReuseIdentifier:tableViewCellIdentifierName];
    [tableView registerClass:[AAMultiSelectTableViewCell class] forCellReuseIdentifier:tableViewCellIdentifierName];
    tableView.dataSource         = self;
    tableView.delegate           = self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view);
        make.right.equalTo(weakself.view);
        make.top.equalTo(weakself.topSeparator.mas_bottom);
    }];
    self.tableView               = tableView;
    
    self.bottomSeparator = [UIView new];
    self.bottomSeparator.backgroundColor = UIColorFromHex(separatorBackgroundColor);
    [self.view addSubview:self.bottomSeparator];
    [self.bottomSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view);
        make.right.equalTo(weakself.view);
        make.top.equalTo(weakself.tableView.mas_bottom).offset(bottomSeparatorMarginTop);
        make.height.mas_equalTo(separatorHeight);
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AAMultiSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifierName
                                                                        forIndexPath:indexPath];
    cell.selectionStyle               = UITableViewCellSelectionStyleNone;
    AAMultiSelectModel *selectModel  = self.dataArray[indexPath.row];
    cell.titleLabel.text              = selectModel.title;
//    cell.selectedImageView.hidden     = !selectModel.isSelected;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AAMultiSelectModel *selectModel = self.dataArray[indexPath.row];
    selectModel.isSelected           = !selectModel.isSelected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)confirmButtonTapped {
    [self.popupView dismiss:YES];
    
    NSMutableArray *selectdArray = [NSMutableArray array];
    for (AAMultiSelectModel *selectModel in self.dataArray) {
        if (selectModel.isSelected) {
            [selectdArray addObject:selectModel];
        }
    }
    AA_SAFE_BLOCK_CALL(self.confirmBlock, [selectdArray copy]);
}

- (void)cancelButtonTapped {
    [self.popupView dismiss:YES];
}

- (void)show {
    self.popupView = [AAPopupView popupWithContentView:self.view
                                              showType:AAPopupViewShowTypeBounceIn
                                           dismissType:AAPopupViewDismissTypeBounceOut
                                              maskType:AAPopupViewMaskTypeDimmed
                              dismissOnBackgroundTouch:YES];
    [self.popupView show];
}

@end


@implementation YCSMultiSelectModel

@end
