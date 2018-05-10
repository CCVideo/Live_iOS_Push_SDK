//
//  UITextView+UserInfo.m
//  NewCCDemo
//
//  Created by cc on 2017/8/14.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "UITextView+UserInfo.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

static char key;

@implementation UITextView (UserInfo)

- (NSObject *)userid {
    return objc_getAssociatedObject(self, &key);
}

- (void)setUserid:(NSObject *)value {
    objc_setAssociatedObject(self, &key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
