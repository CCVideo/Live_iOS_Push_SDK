//
//  ServerChildItem.h
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerChildItemDelegate <NSObject>
@optional

-(void)serverChildItemClicked:(NSInteger)index;

@end



@interface ServerChildItem : UIView

@property(nonatomic,strong)UIButton             *leftBtn;
@property(nonatomic,strong)UILabel              *rightLabel;
@property(nonatomic,strong)UILabel              *leftLabel;
@property(nonatomic,assign)NSInteger            index;

@property (assign,nonatomic) id<ServerChildItemDelegate>    delegate;

- (void)settingWithLineLong:(BOOL)lineLong leftText:(NSString *)leftText rightText:(NSString *)rightText selected:(BOOL)selected;

@end
