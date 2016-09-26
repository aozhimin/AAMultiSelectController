//
//  AAMultiSelectTableViewCell.m
//  Pods
//
//  Created by dev-aozhimin on 16/9/23.
//
//

#import "AAMultiSelectTableViewCell.h"
#import "Masonry.h"

#define AAImage(fileName)   [UIImage imageNamed:[@"AAMultiSelectController.bundle" stringByAppendingPathComponent:fileName]] ? : [UIImage imageNamed:[@"Frameworks/AAMultiSelectController.framework/AAMultiSelectController.bundle" stringByAppendingPathComponent:fileName]]


@interface AAMultiSelectTableViewCell ()

@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UIImageView *selectedImageView;

@end

@implementation AAMultiSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(15);
    }];
    [self addSubview:self.selectedImageView];
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-15);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
    }
    return _titleLabel;
}

- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        _selectedImageView = [UIImageView new];
        _selectedImageView.image = AAImage(@"AAicon_check.png");
    }
    return _selectedImageView;
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title               = title;
        self.titleLabel.text = title;
    }
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    if (_titleTextColor != titleTextColor) {
        _titleTextColor           = titleTextColor;
        self.titleLabel.textColor = titleTextColor;
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (!_titleFont != titleFont) {
        _titleFont           = titleFont;
        self.titleLabel.font = titleFont;
    }
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    if (_selectedImage != selectedImage) {
        _selectedImage               = selectedImage;
        self.selectedImageView.image = selectedImage;
    }
}

- (void)setSelectedImageHidden:(BOOL *)selectedImageHidden {
    _selectedImageHidden          = selectedImageHidden;
    self.selectedImageView.hidden = selectedImageHidden;
}

@end
