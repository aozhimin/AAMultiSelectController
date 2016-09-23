//
//  AAMultiSelectModel.h
//  Pods
//
//  Created by dev-aozhimin on 16/9/23.
//
//

#import <Foundation/Foundation.h>

@interface AAMultiSelectModel : NSObject

@property (nonatomic, assign) NSInteger multiSelectId;
@property (nonatomic, copy  ) NSString  *title;
@property (nonatomic, assign) BOOL      isSelected;

@end
