//
//  ServerList.m
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "ServerList.h"
#import "ServerChildItem.h"
#import "CCPush/CCPushUtil.h"
#import "LoadingView.h"

@interface ServerList ()<ServerChildItemDelegate>

@property(nonatomic,strong)UIBarButtonItem              *leftBarBtn;
@property(nonatomic,strong)UILabel                      *informationLabel;
@property(nonatomic,strong)NSMutableArray               *array;
@property(nonatomic,strong)UIBarButtonItem              *rightBarBtn;
@property(nonatomic,strong)LoadingView                  *loadingView;

@end

@implementation ServerList

-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}

-(void)onSelectVC {
    if(_loadingView) return;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.informationLabel];
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarBtn;
    WS(ws);
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self.dic allKeys]];
    ServerChildItem *lastServer = nil;
    for (NSInteger i = 0; i < arr.count; i++) {
        if([arr[i] isEqualToString:@"全球节点"] && (arr.count - 1) != i) {
            [arr exchangeObjectAtIndex:(arr.count - 1) withObjectAtIndex:i];
            break;
        }
    }
    for (NSInteger i = 0; i < arr.count; i++) {
        ServerChildItem *server = [ServerChildItem new];
        [self.array addObject:server];
        WS(ws)
        int index = [GetFromUserDefaults(SET_SERVER_INDEX) intValue];
        server.index = [self.dic[arr[i]][@"index"] integerValue];
        server.delegate = self;
        if([arr[i] isEqualToString:@"全球节点"]) {
            [server settingWithLineLong:(i==0) leftText:arr[i] rightText:@"" selected:([self.dic[arr[i]][@"index"] integerValue] == index)];
        } else {
            [server settingWithLineLong:(i==0) leftText:arr[i] rightText:self.dic[arr[i]][@"time"] selected:([self.dic[arr[i]][@"index"] integerValue] == index)];
        }
        [self.view addSubview:server];
        
        if(i == 0) {
            [server mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(ws.view);
                make.top.mas_equalTo(ws.informationLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
                make.height.mas_equalTo(CCGetRealFromPt(92));
            }];
        } else {
            [server mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(lastServer);
                make.top.mas_equalTo(lastServer.mas_bottom);
                make.height.mas_equalTo(lastServer.mas_height);
            }];
        }
        lastServer = server;
    }
    
    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(lastServer.mas_bottom);
        make.height.mas_equalTo(1);
    }];
}

-(void)serverChildItemClicked:(NSInteger)index {
    for (ServerChildItem *obj in self.array) {
        if(obj.index == index) {
            obj.leftBtn.selected = YES;
            SaveToUserDefaults(SET_SERVER_INDEX,[NSNumber numberWithInteger:index]);
            NSLog(@"切换线路index = %ld",index);
            [[CCPushUtil sharedInstanceWithDelegate:self] setNodeIndex:index];
        } else {
            obj.leftBtn.selected = NO;
        }
    }
    [self.navigationController popViewControllerAnimated:NO];
}

-(UIBarButtonItem *)rightBarBtn {
    if(_rightBarBtn == nil) {
        _rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"测速" style:UIBarButtonItemStylePlain target:self action:@selector(onSelectTestSpeed)];
        [_rightBarBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize_30],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }
    return _rightBarBtn;
}

-(void)onSelectTestSpeed {
    if(_loadingView) return;
    _loadingView = [[LoadingView alloc] initWithLabel:@"测速中..." centerY:NO];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
    [[CCPushUtil sharedInstanceWithDelegate:self]testSpeed];
}

/**
 *    @brief    返回节点列表，节点测速时间，以及最优点索引(从0开始，如果无最优点，随机获取节点当作最优节点)
 */
- (void) nodeListDic:(NSMutableDictionary*)dic bestNodeIndex:(NSInteger)index {
    //    NSLog(@"second---dic = %@,index = %ld",dic,index);
    NSLog(@"切换线路index = %ld",index);
    SaveToUserDefaults(SET_SERVER_INDEX,[NSNumber numberWithInteger:index]);
    [[CCPushUtil sharedInstanceWithDelegate:self] setNodeIndex:index];
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    NSArray *arr = [dic allKeys];
    for (NSInteger i = 0; i < arr.count; i++) {
        for(NSInteger j = 0;j < self.array.count;j++) {
            ServerChildItem *server = (ServerChildItem *)[self.array objectAtIndex:j];
            if([arr[i] isEqualToString:server.leftLabel.text]) {
                if([arr[i] isEqualToString:@"全球节点"]) {
                    server.rightLabel.text = @"";
                } else {
                    server.rightLabel.text = dic[arr[i]][@"time"];
                }
                server.index = [dic[arr[i]][@"index"] integerValue];
                server.leftBtn.selected = ([dic[arr[i]][@"index"] integerValue] == index);
            }
        }
    }
}

-(NSMutableArray *)array {
    if(!_array) {
        _array = [[NSMutableArray alloc] init];
    }
    return _array;
}

-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [UILabel new];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:@"选择服务器"];
    }
    return _informationLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
