//
//  PushViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "PushViewController.h"
#import "InformationShowView.h"
#import "ModelView.h"
#import "CCPublicTableViewCell.h"
#import "CustomTextField.h"
#import "CCPrivateChatView.h"
#import "AGImagePickerController.h"

@interface PushViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIView               *preView;
@property(nonatomic,strong)UIView               *informationView;
@property(nonatomic,strong)UILabel              *hostNameLabel;
@property(nonatomic,strong)UILabel              *userCountLabel;
@property(nonatomic,strong)UILabel              *timePastLabel;
@property(nonatomic,strong)NSTimer              *timer;

@property(nonatomic,strong)UIButton             *publicChatBtn;
@property(nonatomic,strong)UIButton             *privateChatBtn;
@property(nonatomic,strong)UIButton             *publishPicBtn;
//@property(nonatomic,strong)UIButton             *cameraChangeBtn;
@property(nonatomic,strong)UIButton             *micChangeBtn;
@property(nonatomic,strong)UIButton             *beautifulBtn;
@property(nonatomic,strong)UIButton             *closeBtn;

@property(nonatomic,strong)ModelView            *modelView;
@property(nonatomic,strong)UIView               *modeoCenterView;
@property(nonatomic,strong)UILabel              *modeoCenterLabel;
@property(nonatomic,strong)UIButton             *cancelBtn;
@property(nonatomic,strong)UIButton             *sureBtn;

@property(nonatomic,strong)CustomTextField      *chatTextField;
@property(nonatomic,strong)UIButton             *sendButton;
@property(nonatomic,strong)UIView               *contentView;
@property(nonatomic,strong)UIButton             *rightView;

@property(nonatomic,strong)UITableView          *tableView;
@property(nonatomic,strong)NSMutableArray       *tableArray;
@property(nonatomic,copy)NSString               *antename;
@property(nonatomic,copy)NSString               *anteid;

@property(nonatomic,strong)UIImageView          *contentBtnView;
@property(nonatomic,strong)UIView               *emojiView;
@property(nonatomic,assign)CGRect               keyboardRect;
@property(nonatomic,strong)CCPrivateChatView    *ccPrivateChatView;

@property(nonatomic,strong)NSMutableDictionary  *dataPrivateDic;
@property(nonatomic,copy)  NSString             *viewerId;
@property(nonatomic,strong)InformationShowView  *informationViewPop;

@property(nonatomic,strong)AGImagePickerController *ipc;
@property(nonatomic,strong) NSMutableArray      *selectedPhotos;
@property(nonatomic,assign) int                 currentShowImageIndex;
@property(nonatomic,strong) UIImage             *currentShowImage;
@property(nonatomic,strong) UILabel             *detailLabel;
@property(nonatomic,assign) BOOL                isBig;
@property(nonatomic,assign)BOOL                 isCameraFront;
@property(nonatomic,strong)NSMutableDictionary      *userDic;
@property(nonatomic,strong)NSTimer              *passTimer;
@property(nonatomic,assign)NSTimeInterval       timeStartPush;

@end

@implementation PushViewController

-(instancetype)initWithViwerid:(NSString *)viewerId {
    self = [super init];
    if(self) {
        self.viewerId = viewerId;
        self.isBig = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    // Do any additional setup after loading the view.
    
    [self initUI];
    
    [self addObserver];
    
    [self startTimer];
    
    [[CCPushUtil sharedInstanceWithDelegate:self] setPreview:_preView];
    
    _isCameraFront = [GetFromUserDefaults(SET_CAMERA_DIRECTION) isEqualToString:@"前置摄像头"];
    [[CCPushUtil sharedInstanceWithDelegate:self] startPushWithCameraFront:_isCameraFront];
}

-(NSMutableDictionary *)userDic {
    if(!_userDic) {
        _userDic = [[NSMutableDictionary alloc] init];
    }
    return _userDic;
}

-(NSDictionary *)dataPrivateDic {
    if(!_dataPrivateDic) {
        _dataPrivateDic = [[NSMutableDictionary alloc] init];
    }
    return _dataPrivateDic;
}

-(void) stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];
}

-(void)startPassTimer {
    [self stopPassTimer];
    _passTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timePassed) userInfo:nil repeats:YES];
}

-(void)stopPassTimer {
    if([_passTimer isValid]) {
        [_passTimer invalidate];
        _passTimer = nil;
    }
}

-(void)timePassed {
    if(self.timeStartPush == 0) return;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timePassedCount = time - self.timeStartPush;
    self.timePastLabel.text = [NSString stringWithFormat:@"直播中：%02d:%02d",(int)timePassedCount / 60,(int)timePassedCount % 60];
}

- (void)timerfunc {
    [[CCPushUtil sharedInstanceWithDelegate:self] roomContext];
    [[CCPushUtil sharedInstanceWithDelegate:self] roomUserCount];
}

-(ModelView *)modelView {
    if(!_modelView) {
        _modelView = [ModelView new];
        _modelView.backgroundColor = CCClearColor;
    }
    return _modelView;
}

-(UIView *)modeoCenterView {
    if(!_modeoCenterView) {
        _modeoCenterView = [UIView new];
        _modeoCenterView.backgroundColor = [UIColor whiteColor];
        _modeoCenterView.layer.borderWidth = 1;
        _modeoCenterView.layer.borderColor = [CCRGBColor(187, 187, 187) CGColor];
        _modeoCenterView.layer.cornerRadius = CCGetRealFromPt(10);
        _modeoCenterView.layer.masksToBounds = YES;
    }
    return _modeoCenterView;
}

-(UIButton *)cancelBtn {
    if(!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.backgroundColor = [UIColor whiteColor];
        _cancelBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _cancelBtn.layer.masksToBounds = YES;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:CCRGBColor(51,51,51) forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

-(UIButton *)sureBtn {
    if(!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.backgroundColor = [UIColor whiteColor];
        _sureBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _sureBtn.layer.masksToBounds = YES;
        [_sureBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:CCRGBColor(51,51,51) forState:UIControlStateNormal];
        [_sureBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_30]];
        [_sureBtn addTarget:self action:@selector(sureBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

-(CGSize)getTitleSizeByFont:(NSString *)str font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(20000.0f, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

-(void)initUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.preView];
    WS(ws)
    [_preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    [self.view addSubview:self.informationView];
    NSString *userName = [@"主播：" stringByAppendingString:GetFromUserDefaults(LIVE_USERNAME)];
    NSString *userCount = @"在线人数：3000人";
    CGSize userNameSize = [self getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSize_26]];
    CGSize userCountSize = [self getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSize_26]];

    CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
    
    if(size.width > self.view.frame.size.width * 0.35) {
        size.width = self.view.frame.size.width * 0.35;
    }

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.detailLabel];
    [self.view addSubview:self.contentBtnView];
    self.currentShowImageIndex = 0;
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(70));
        make.width.mas_equalTo(CCGetRealFromPt(100));
        make.height.mas_equalTo(CCGetRealFromPt(28));
    }];
    
    // 双击的 Recognizer
    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(DoubleTap:)];
    [self.view addGestureRecognizer:doubleRecognizer];
    doubleRecognizer.numberOfTapsRequired = 2; // 双击
    [self.view addGestureRecognizer:doubleRecognizer];
    
    // 单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(SingleTap:)];
    [self.view addGestureRecognizer:singleRecognizer];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:singleRecognizer];
    
    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    
    UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFromRight:)];
    [recognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizerRight];

    UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFromLeft:)];
    [recognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizerLeft];
    
    [self.contentBtnView addSubview:self.publicChatBtn];
    [self.contentBtnView addSubview:self.privateChatBtn];
    [self.contentBtnView addSubview:self.publishPicBtn];
    [self.contentBtnView addSubview:self.micChangeBtn];
    [self.contentBtnView addSubview:self.beautifulBtn];
    [self.contentBtnView addSubview:self.closeBtn];
    
    [self.view addSubview:self.ccPrivateChatView];
    
    [self.ccPrivateChatView setCheckDotBlock1:^(BOOL flag) {
        ws.privateChatBtn.selected = flag;
    }];
    
    _publishPicBtn.selected = YES;
    BOOL beauti = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_BEAUTIFUL] boolValue];
    _beautifulBtn.selected = beauti;
    
    if(!self.isScreenLandScape) {
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(80));
            make.width.mas_equalTo(CCGetRealFromPt(30) + size.width + CCGetRealFromPt(40));
            make.height.mas_equalTo(CCGetRealFromPt(130));
        }];
        
        [_contentBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(130));
        }];
        
        [_publicChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
        }];
        
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.publicChatBtn);
            make.size.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_beautifulBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.closeBtn.mas_left).offset(-CCGetRealFromPt(20));
            make.bottom.mas_equalTo(ws.closeBtn);
            make.size.mas_equalTo(ws.closeBtn);
        }];
        
        [_micChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.beautifulBtn.mas_left).offset(-CCGetRealFromPt(20));
            make.bottom.mas_equalTo(ws.beautifulBtn);
            make.size.mas_equalTo(ws.beautifulBtn);
        }];
        
        [_publishPicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.micChangeBtn.mas_left).offset(-CCGetRealFromPt(20));
            make.bottom.mas_equalTo(ws.micChangeBtn);
            make.size.mas_equalTo(ws.micChangeBtn);
        }];
        
        [_privateChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.publishPicBtn.mas_left).offset(-CCGetRealFromPt(20));
            make.bottom.mas_equalTo(ws.publishPicBtn);
            make.size.mas_equalTo(ws.publishPicBtn);
        }];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
        }];
        
        [self.view addSubview:self.contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [self.contentView addSubview:self.chatTextField];
        [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(24));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(556), CCGetRealFromPt(84)));
        }];
        
        [self.contentView addSubview:self.sendButton];
        [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(24));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(120), CCGetRealFromPt(84)));
        }];
        
        self.contentView.hidden = YES;
        
        [_ccPrivateChatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(542));
            make.bottom.mas_equalTo(ws.view).offset(CCGetRealFromPt(542));
        }];
    } else {
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(80));
            make.width.mas_equalTo(CCGetRealFromPt(30) + size.width + CCGetRealFromPt(40));
            make.height.mas_equalTo(CCGetRealFromPt(130));
        }];
        
        [_contentBtnView setImage:[UIImage imageNamed:@"Rectangle1"]];
        [_contentBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.and.right.mas_equalTo(ws.view);
            make.width.mas_equalTo(CCGetRealFromPt(130));
        }];
        
        [_publicChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(30));
            make.right.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
        }];
        
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(70));
            make.right.mas_equalTo(ws.publicChatBtn);
            make.size.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_beautifulBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.closeBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.right.mas_equalTo(ws.closeBtn);
            make.size.mas_equalTo(ws.closeBtn);
        }];
        
        [_micChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.beautifulBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.right.mas_equalTo(ws.beautifulBtn);
            make.size.mas_equalTo(ws.beautifulBtn);
        }];
        
        [_publishPicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.micChangeBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.right.mas_equalTo(ws.micChangeBtn);
            make.size.mas_equalTo(ws.micChangeBtn);
        }];
        
        [_privateChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.publishPicBtn.mas_bottom).offset(CCGetRealFromPt(20));
            make.right.mas_equalTo(ws.publishPicBtn);
            make.size.mas_equalTo(ws.publishPicBtn);
        }];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(40));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(700),CCGetRealFromPt(300)));
        }];
        
        [self.view addSubview:self.contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];

        [self.contentView addSubview:self.chatTextField];
        [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(1134), CCGetRealFromPt(84)));
        }];

        [self.contentView addSubview:self.sendButton];
        [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.contentView.mas_centerY);
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(30));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(120), CCGetRealFromPt(84)));
        }];

        self.contentView.hidden = YES;
        
        [_ccPrivateChatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(444));
            make.bottom.mas_equalTo(ws.view).offset(CCGetRealFromPt(444));
        }];
    }
}

-(CCPrivateChatView *)ccPrivateChatView {
    if(!_ccPrivateChatView) {
        WS(ws)
        _ccPrivateChatView = [[CCPrivateChatView alloc] initWithCloseBlock:^{
            [ws.ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.mas_equalTo(ws.view);
                make.height.mas_equalTo(CCGetRealFromPt(542));
                make.bottom.mas_equalTo(ws.view).offset(CCGetRealFromPt(542));
            }];
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [ws.ccPrivateChatView showTableView];
                if(ws.ccPrivateChatView.privateChatViewForOne) {
                    [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
                    ws.ccPrivateChatView.privateChatViewForOne = nil;
                }
            }];
        } isResponseBlock:^(CGFloat y) {
//            NSLog(@"PushViewController isResponseBlock y = %f",y);
            if(!ws.isScreenLandScape) {
                [ws.ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.mas_equalTo(ws.view);
                    make.height.mas_equalTo(CCGetRealFromPt(542));
                    make.bottom.mas_equalTo(ws.view).mas_offset(-y);
                }];
            } else {
                [ws.ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.mas_equalTo(ws.view);
                    make.height.mas_equalTo(ws.view.frame.size.height-_keyboardRect.size.height);
                    make.bottom.mas_equalTo(ws.view).offset(-_keyboardRect.size.height);
                }];
            }
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        } isNotResponseBlock:^{
            if(!ws.isScreenLandScape) {
                [ws.ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.mas_equalTo(ws.view);
                    make.height.mas_equalTo(CCGetRealFromPt(542));
                    make.bottom.mas_equalTo(ws.view);
                }];
            } else {
                [ws.ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.mas_equalTo(ws.view);
                    make.height.mas_equalTo(CCGetRealFromPt(444));
                    make.bottom.mas_equalTo(ws.view);
                }];
            }
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }  dataPrivateDic:[self.dataPrivateDic copy] isScreenLandScape:_isScreenLandScape];
    }
    return _ccPrivateChatView;
}

-(UIView *)informationView {
    if(!_informationView) {
        _informationView = [UIView new];
        _informationView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
        _informationView.layer.cornerRadius = CCGetRealFromPt(10);
        _informationView.layer.masksToBounds = YES;
        WS(ws)
        [_informationView addSubview:self.hostNameLabel];
        [_hostNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(13));
            make.right.mas_equalTo(ws.informationView).offset(-CCGetRealFromPt(40));
            make.height.mas_equalTo(CCGetRealFromPt(26));
        }];
        [_informationView addSubview:self.userCountLabel];
        [_userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.height.mas_equalTo(ws.hostNameLabel);
            make.top.mas_equalTo(ws.hostNameLabel.mas_bottom).offset(CCGetRealFromPt(14));
        }];
        [_informationView addSubview:self.timePastLabel];
        [_timePastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.height.mas_equalTo(ws.userCountLabel);
            make.top.mas_equalTo(ws.userCountLabel.mas_bottom).offset(CCGetRealFromPt(14));
        }];
    }
    return _informationView;
}

-(UILabel *)hostNameLabel {
    if(!_hostNameLabel) {
        _hostNameLabel = [UILabel new];
        _hostNameLabel.font = [UIFont systemFontOfSize:FontSize_26];
        _hostNameLabel.textAlignment = NSTextAlignmentLeft;
        _hostNameLabel.textColor = [UIColor whiteColor];
        _hostNameLabel.text = [NSString stringWithFormat:@"主播：%@",GetFromUserDefaults(LIVE_USERNAME)];
    }
    return _hostNameLabel;
}

-(UILabel *)detailLabel {
    if(!_detailLabel) {
        _detailLabel = [UILabel new];
        _detailLabel.font = [UIFont systemFontOfSize:FontSize_28];
        _detailLabel.shadowOffset = CGSizeMake(0, 1);
        _detailLabel.shadowColor = CCRGBAColor(255, 255, 255, 0.5);
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.textColor = CCRGBColor(51,51,51);
    }
    return _detailLabel;
}

-(UILabel *)userCountLabel {
    if(!_userCountLabel) {
        _userCountLabel = [UILabel new];
        _userCountLabel.font = [UIFont systemFontOfSize:FontSize_26];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        _userCountLabel.textColor = [UIColor whiteColor];
        _userCountLabel.text = @"在线人数：1人";
    }
    return _userCountLabel;
}

-(UILabel *)timePastLabel {
    if(!_timePastLabel) {
        _timePastLabel = [UILabel new];
        _timePastLabel.font = [UIFont systemFontOfSize:FontSize_26];
        _timePastLabel.textAlignment = NSTextAlignmentLeft;
        _timePastLabel.textColor = [UIColor whiteColor];
        _timePastLabel.text = @"直播中：00:00";
    }
    return _timePastLabel;
}

//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//设置是否隐藏
- (BOOL)prefersStatusBarHidden {
    return NO;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)preView {
    if(!_preView) {
        _preView = [UIView new];
        _preView.backgroundColor = CCClearColor;
    }
    return _preView;
}

/**
 *	@brief	正在连接网络，UI不可动
 */
- (void) isConnectionNetWork {

}
/**
 *	@brief	连接网络完成
 */
- (void) connectedNetWorkFinished {

}

/**
 *	@brief	设置连接状态
 */
- (void) setConnectionStatus:(NSInteger)status {
    switch (status) {
        case 1:
            NSLog(@"正在连接");
            break;
        case 3:
            if(self.timeStartPush == 0) {
                self.timeStartPush = [[NSDate date] timeIntervalSince1970];
                [self startPassTimer];
            }
            NSLog(@"已连接");
            break;
        case 5:
            NSLog(@"未连接");
            break;
        default:
            break;
    }
}

/**
 *	@brief	推流失败
 */
-(void)pushFailed:(NSError *)error reason:(NSString *)reason {
//    NSString *message = nil;
//    if (reason == nil) {
//        message = [error localizedDescription];
//    } else {
//        message = reason;
//    }
//    [_informationViewPop removeFromSuperview];
//    _informationViewPop = [[InformationShowView alloc] initWithLabel:message];
//    [self.view addSubview:_informationViewPop];
//    [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
//
//    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
    
    NSString *message = nil;
    if (reason == nil) {
        message = [error localizedDescription];
    } else {
        message = reason;
    }
    [self stopPassTimer];
    self.timeStartPush = 0;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"推流失败" message:[@"原因：" stringByAppendingString:message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self removeObserver];
    [self.modelView removeFromSuperview];
    [self stopTimer];
    [[CCPushUtil sharedInstanceWithDelegate:self] stopPush];
    [CCPushUtil sharedInstanceWithDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:^ {
    }];
}

-(void)removeInformationViewPop {
    [_informationViewPop removeFromSuperview];
    _informationViewPop = nil;
}

-(UIButton *)publicChatBtn {
    if(!_publicChatBtn) {
        _publicChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publicChatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"home_ic_chat_nor"] forState:UIControlStateNormal];
        [_publicChatBtn addTarget:self action:@selector(publicChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publicChatBtn;
}

-(void)publicChatBtnClicked {
    [_chatTextField becomeFirstResponder];
}

-(UIButton *)privateChatBtn {
    if(!_privateChatBtn) {
        _privateChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_privateChatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_privateChatBtn setBackgroundImage:[UIImage imageNamed:@"home_ic_news_nor"] forState:UIControlStateNormal];
        [_privateChatBtn setBackgroundImage:[UIImage imageNamed:@"home_ic_newsmsg_nor"] forState:UIControlStateSelected];
        [_privateChatBtn addTarget:self action:@selector(privateChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _privateChatBtn;
}

-(void)privateChatBtnClicked {
    WS(ws)
    if(!self.isScreenLandScape) {
        [_ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(542));
            make.bottom.mas_equalTo(ws.view);
        }];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

-(UIButton *)publishPicBtn {
    if(!_publishPicBtn) {
        _publishPicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishPicBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_publishPicBtn setBackgroundImage:[UIImage imageNamed:@"publish_pic_hor"] forState:UIControlStateNormal];
        [_publishPicBtn setBackgroundImage:[UIImage imageNamed:@"publish_pic_nor"] forState:UIControlStateSelected];
        [_publishPicBtn addTarget:self action:@selector(publishPicBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishPicBtn;
}

-(UIButton *)micChangeBtn {
    if(!_micChangeBtn) {
        _micChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_micChangeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_micChangeBtn setBackgroundImage:[UIImage imageNamed:@"home_ic_sound_nor"] forState:UIControlStateNormal];
        [_micChangeBtn setBackgroundImage:[UIImage imageNamed:@"home_ic_sound_ban"] forState:UIControlStateSelected];
        [_micChangeBtn addTarget:self action:@selector(micChangeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micChangeBtn;
}

-(void)micChangeBtnClicked {
    _micChangeBtn.selected = !_micChangeBtn.selected;
    if(_micChangeBtn.selected) {
        [[CCPushUtil sharedInstanceWithDelegate:self] setMicGain:0];
    } else {
        [[CCPushUtil sharedInstanceWithDelegate:self] setMicGain:10];
    }
}

-(UIButton *)beautifulBtn {
    if(!_beautifulBtn) {
        _beautifulBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beautifulBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_beautifulBtn setBackgroundImage:[UIImage imageNamed:@"home_ic_beauty_ban"] forState:UIControlStateNormal];
        [_beautifulBtn setBackgroundImage:[UIImage imageNamed:@"home_ic_beauty_nor"] forState:UIControlStateSelected];
        [_beautifulBtn addTarget:self action:@selector(beautifulBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautifulBtn;
}

-(void)beautifulBtnClicked {
    _beautifulBtn.selected = !_beautifulBtn.selected;
    if(_beautifulBtn.selected) {
        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0.5 white:0.5 pink:0.5];
    } else {
        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0 white:0 pink:0];
    }
}

-(UIButton *)closeBtn {
    if(!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"home_ic_close_nor"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(void)closeBtnClicked {
    [self.view addSubview:self.modelView];
    WS(ws)
    [_modelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    [_modelView addSubview:self.modeoCenterView];
    [_modeoCenterView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(!ws.isScreenLandScape) {
            make.top.mas_equalTo(ws.modelView).offset(CCGetRealFromPt(390));
        } else {
            make.centerY.mas_equalTo(ws.modelView.mas_centerY);
        }
        make.centerX.mas_equalTo(ws.modelView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(500), CCGetRealFromPt(250)));
    }];
    [_modeoCenterView addSubview:self.cancelBtn];
    [_modeoCenterView addSubview:self.sureBtn];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.mas_equalTo(ws.modeoCenterView);
        make.height.mas_equalTo(CCGetRealFromPt(100));
        make.right.mas_equalTo(ws.sureBtn.mas_left);
        make.width.mas_equalTo(ws.sureBtn.mas_width);
    }];
    
    [_sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.mas_equalTo(ws.modeoCenterView);
        make.height.mas_equalTo(ws.cancelBtn);
        make.left.mas_equalTo(ws.cancelBtn.mas_right);
        make.width.mas_equalTo(ws.cancelBtn.mas_width);
    }];
    
    [_modelView addSubview:self.modeoCenterLabel];
    [_modeoCenterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(ws.modeoCenterView);
        make.bottom.mas_equalTo(ws.sureBtn.mas_top);
    }];
    
    UIView *lineCross = [UIView new];
    lineCross.backgroundColor = CCRGBColor(221,221,221);
    [_modeoCenterView addSubview:lineCross];
    [lineCross mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.modeoCenterView);
        make.bottom.mas_equalTo(ws.cancelBtn.mas_top);
        make.height.mas_equalTo(1);
    }];
    
    UIView *lineVertical = [UIView new];
    lineVertical.backgroundColor = CCRGBColor(221,221,221);
    [_modeoCenterView addSubview:lineVertical];
    [lineVertical mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.cancelBtn.mas_right);
        make.top.mas_equalTo(lineCross.mas_bottom);
        make.bottom.mas_equalTo(ws.cancelBtn.mas_bottom);
        make.width.mas_equalTo(1);
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

-(void)sureBtnClicked {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self removeObserver];
    [self.modelView removeFromSuperview];
    [self stopTimer];
    [self stopPassTimer];
    self.timeStartPush = 0;
    [[CCPushUtil sharedInstanceWithDelegate:self] stopPush];
    [CCPushUtil sharedInstanceWithDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:^ {
    }];
}

-(void)cancelBtnClicked {
    [self.modelView removeFromSuperview];
}

-(UILabel *)modeoCenterLabel {
    if(!_modeoCenterLabel) {
        _modeoCenterLabel = [UILabel new];
        _modeoCenterLabel.font = [UIFont systemFontOfSize:FontSize_30];
        _modeoCenterLabel.textAlignment = NSTextAlignmentCenter;
        _modeoCenterLabel.textColor = CCRGBColor(51,51,51);
        _modeoCenterLabel.text = @"您确认结束直播吗？";
    }
    return _modeoCenterLabel;
}

#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.chatTextField resignFirstResponder];
    [self.ccPrivateChatView.privateChatViewForOne.chatTextField resignFirstResponder];
    WS(ws)

    [_ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(542));
        make.bottom.mas_equalTo(ws.view).offset(CCGetRealFromPt(542));
    }];
    
    [_ccPrivateChatView showTableView];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.ccPrivateChatView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [ws.ccPrivateChatView showTableView];
        if(ws.ccPrivateChatView.privateChatViewForOne) {
            [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
            ws.ccPrivateChatView.privateChatViewForOne = nil;
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellPush";
    
    Dialogue *dialogue = [_tableArray objectAtIndex:indexPath.row];

    WS(ws)
    CCPublicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CCPublicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier dialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
            [ws.chatTextField resignFirstResponder];
            if([anteid isEqualToString:dialogue.myViwerId] || ws.isScreenLandScape) return;
            NSMutableArray *array = [ws.dataPrivateDic objectForKey:anteid];
            
            NSString *userName = nil;
            NSRange range = [dialogue.username rangeOfString:@": "];
            if(range.location != NSNotFound) {
                userName = [dialogue.username substringToIndex:range.location];
            } else {
                userName = dialogue.username;
            }
            
            CCLog(@"111 userName = %@",dialogue.username);
            
            [ws.ccPrivateChatView createPrivateChatViewForOne:[array copy] anteid:dialogue.userid  anteName:userName];
            
            [ws.ccPrivateChatView selectByClickHead:dialogue];
            
            [ws privateChatBtnClicked];
        }];
    } else {
        [cell reloadWithDialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
            [ws.chatTextField resignFirstResponder];
            if([anteid isEqualToString:dialogue.myViwerId] || ws.isScreenLandScape) return;
            NSMutableArray *array = [ws.dataPrivateDic objectForKey:anteid];
            
            NSString *userName = nil;
            NSRange range = [dialogue.username rangeOfString:@": "];
            if(range.location != NSNotFound) {
                userName = [dialogue.username substringToIndex:range.location];
            } else {
                userName = dialogue.username;
            }
            
            CCLog(@"111 userName = %@",dialogue.username);
            
            [ws.ccPrivateChatView createPrivateChatViewForOne:[array copy] anteid:dialogue.userid anteName:userName];
            
            [ws.ccPrivateChatView selectByClickHead:dialogue];
            
            [ws privateChatBtnClicked];
        }];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Dialogue *dialogue = [self.tableArray objectAtIndex:indexPath.row];
    return dialogue.msgSize.height + 10;
}

/**
 *	@brief	点击开始推流按钮，获取liveid
 */
- (void) getLiveidBeforPush:(NSString *)liveid {
//    NSLog(@"liveid = %@",liveid);
}

- (void)room_user_count:(NSString *)str {
    self.userCountLabel.text = [NSString stringWithFormat:@"在线人数：%@人",str];
}

- (void)receivePublisherId:(NSString *)str onlineUsers:(NSMutableDictionary *)dict {
    //    _publisherId = str;
    //    _onlineUsers = dict;
}

- (void)stopPushSuccessful {
    //    NSLog(@"退出推流成功！");
}

- (void)on_chat_message:(NSString *)str {
    NSLog(@"on_chat_message = %@",str);
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.fromuserid = dic[@"userid"];
    dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.fromusername = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.userrole = dic[@"userrole"];
    dialogue.fromuserrole = dic[@"userrole"];
    dialogue.msg = dic[@"msg"];
    dialogue.useravatar = dic[@"useravatar"];
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = _viewerId;
    
    if([self.userDic objectForKey:dialogue.userid] == nil) {
        [self.userDic setObject:dic[@"username"] forKey:dialogue.userid];
    }
    
    dialogue.msgSize = [self getTitleSizeByFont:[dialogue.username stringByAppendingString:dialogue.msg] width:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSize_32]];
    
    dialogue.userNameSize = [self getTitleSizeByFont:dialogue.username width:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSize_32]];
    
    [_tableArray addObject:dialogue];
    
    if([_tableArray count] >= 1){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_tableArray count]-1) inSection:0];
            [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void)on_private_chat:(NSString *)str {
    NSLog(@"on_private_chat = %@",str);
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    
    if(dic[@"fromuserid"] && dic[@"fromusername"] && [self.userDic objectForKey:dic[@"fromuserid"]] == nil) {
        [self.userDic setObject:dic[@"fromusername"] forKey:dic[@"fromuserid"]];
    }
    if(dic[@"touserid"] && dic[@"tousername"] && [self.userDic objectForKey:dic[@"touserid"]] == nil) {
        [self.userDic setObject:dic[@"tousername"] forKey:dic[@"touserid"]];
    }
    
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"fromuserid"];
    dialogue.fromuserid = dic[@"fromuserid"];
    dialogue.username = dic[@"fromusername"];
    dialogue.fromusername = dic[@"fromusername"];
    dialogue.fromuserrole = dic[@"fromuserrole"];
    dialogue.useravatar = dic[@"useravatar"];
    dialogue.touserid = dic[@"touserid"];
    dialogue.msg = dic[@"msg"];
    dialogue.time = dic[@"time"];
    dialogue.tousername = self.userDic[dialogue.touserid];
    dialogue.myViwerId = _viewerId;
    
    dialogue.msgSize = [self getTitleSizeByFont:[dialogue.username stringByAppendingString:dialogue.msg] width:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSize_32]];
    
    dialogue.userNameSize = [self getTitleSizeByFont:dialogue.username width:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSize_32]];
    
    NSString *anteName = nil;
    NSString *anteid = nil;
    if([dialogue.fromuserid isEqualToString:self.viewerId]) {
        anteid = dialogue.touserid;
        anteName = dialogue.tousername;
    } else {
        anteid = dialogue.fromuserid;
        anteName = dialogue.fromusername;
    }

    NSMutableArray *array = [self.dataPrivateDic objectForKey:anteid];
    if(!array) {
        array = [[NSMutableArray alloc] init];
        [self.dataPrivateDic setValue:array forKey:anteid];
    }

    [array addObject:dialogue];
    
    [self.ccPrivateChatView reloadDict:[self.dataPrivateDic mutableCopy] anteName:anteName anteid:anteid];
}

-(CGSize)getTitleSizeByFont:(NSString *)str width:(CGFloat)width font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self chatSendMessage];
    return YES;
}

-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    
    [[CCPushUtil sharedInstanceWithDelegate:self] chatMessage:str];
    
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(privateChat:)
                                                 name:@"private_Chat"
                                               object:nil];
}

- (void) privateChat:(NSNotification*) notification
{
    NSDictionary *dic = [notification object];
    
    [[CCPushUtil sharedInstanceWithDelegate:self]privateChatWithTouserid:dic[@"anteid"] msg:dic[@"str"]];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"private_Chat"
                                                  object:nil];
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
//    CGFloat x = _keyboardRect.size.width;
//    NSLog(@"键盘高度是  %d",(int)y);
//    NSLog(@"键盘宽度是  %d",(int)x);
    if(!self.isScreenLandScape) {
        if ([self.chatTextField isFirstResponder]) {
            self.contentBtnView.hidden = YES;
            self.contentView.hidden = NO;
            WS(ws)
            [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.mas_equalTo(ws.view);
                make.bottom.mas_equalTo(ws.view).offset(-y);
                make.height.mas_equalTo(CCGetRealFromPt(110));
            }];
            
            [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            }];
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
    } else {
        if ([self.chatTextField isFirstResponder]) {
            WS(ws)
            self.contentView.hidden = NO;
            
            [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.mas_equalTo(ws.view);
                make.bottom.mas_equalTo(ws.view).offset(-y);
                make.height.mas_equalTo(CCGetRealFromPt(110));
            }];

            [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(ws.view).offset(-y-CCGetRealFromPt(110));
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(700),CCGetRealFromPt(300)));
            }];
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    WS(ws)
    if(!self.isScreenLandScape) {
        self.contentBtnView.hidden = NO;
        self.contentView.hidden = YES;
        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
        }];
    } else {
        self.contentView.hidden = YES;
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.view).offset(-CCGetRealFromPt(40));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(700),CCGetRealFromPt(300)));
        }];
        
        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.contentView.hidden = YES;
        [ws.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = CCRGBAColor(171,179,189,0.30);
    }
    return _contentView;
}

-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [CustomTextField new];
        _chatTextField.delegate = self;
        [_chatTextField addTarget:self action:@selector(chatTextFieldChange) forControlEvents:UIControlEventEditingChanged];
        _chatTextField.rightView = self.rightView;
    }
    return _chatTextField;
}

-(void)chatTextFieldChange {
    NSLog(@"== %ld",_chatTextField.text.length);
    if(_chatTextField.text.length > 300) {
//        [self.view endEditing:YES];
        
        _chatTextField.text = [_chatTextField.text substringToIndex:300];
        [_informationViewPop removeFromSuperview];
        _informationViewPop = [[InformationShowView alloc] initWithLabel:@"输入限制在300个字符以内"];
        [APPDelegate.window addSubview:_informationViewPop];
        [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
    }
}

-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightView.frame = CGRectMake(0, 0, CCGetRealFromPt(48), CCGetRealFromPt(48));
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_nor"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_hov"] forState:UIControlStateSelected];
        [_rightView addTarget:self action:@selector(faceBoardClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}

- (void)faceBoardClick {
    BOOL selected = !_rightView.selected;
    _rightView.selected = selected;
    
    if(selected) {
        [_chatTextField setInputView:self.emojiView];
    } else {
        [_chatTextField setInputView:nil];
    }
    
    [_chatTextField becomeFirstResponder];
    [_chatTextField reloadInputViews];
}

-(UIButton *)sendButton {
    if(!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.backgroundColor = CCRGBColor(255,102,51);
        _sendButton.layer.cornerRadius = CCGetRealFromPt(4);
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.borderColor = [CCRGBColor(255,71,0) CGColor];
        _sendButton.layer.borderWidth = 1;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:CCRGBColor(255,255,255) forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_sendButton addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

-(void)sendBtnClicked {
    if(!StrNotEmpty([_chatTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
        [_informationViewPop removeFromSuperview];
        _informationViewPop = [[InformationShowView alloc] initWithLabel:@"发送内容为空"];
        [APPDelegate.window addSubview:_informationViewPop];
        [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
        return;
    }
    [self chatSendMessage];
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(UIImageView *)contentBtnView {
    if(!_contentBtnView) {
        _contentBtnView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rectangle"]];
        _contentBtnView.userInteractionEnabled = YES;
        _contentBtnView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _contentBtnView;
}

-(UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
//        _tableView.backgroundColor = [UIColor grayColor];
    }
    return _tableView;
}

-(NSMutableArray *)tableArray {
    if(!_tableArray) {
        _tableArray = [[NSMutableArray alloc] init];
    }
    return _tableArray;
}

-(UIView *)emojiView {
    if(!_emojiView) {
        if(_keyboardRect.size.width == 0 || _keyboardRect.size.height ==0) {
            _keyboardRect = CGRectMake(0, 0, 414, 271);
        }
        _emojiView = [[UIView alloc] initWithFrame:_keyboardRect];
        _emojiView.backgroundColor = CCRGBColor(242,239,237);

        CGFloat faceIconSize = CCGetRealFromPt(60);
        CGFloat xspace = (_keyboardRect.size.width - FACE_COUNT_CLU * faceIconSize) / (FACE_COUNT_CLU + 1);
        CGFloat yspace = (_keyboardRect.size.height - 26 - FACE_COUNT_ROW * faceIconSize) / (FACE_COUNT_ROW + 1);
        
        for (int i = 0; i < FACE_COUNT_ALL; i++) {
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = i + 1;
            
            [faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (i % FACE_COUNT_CLU + 1) * xspace + (i % FACE_COUNT_CLU) * faceIconSize;
            CGFloat y = (i / FACE_COUNT_CLU + 1) * yspace + (i / FACE_COUNT_CLU) * faceIconSize;
            
            faceButton.frame = CGRectMake(x, y, faceIconSize, faceIconSize);
            faceButton.backgroundColor = CCClearColor;
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d", i+1]]
                        forState:UIControlStateNormal];
            faceButton.contentMode = UIViewContentModeScaleAspectFit;
            [_emojiView addSubview:faceButton];
        }
        //删除键
        UIButton *button14 = (UIButton *)[_emojiView viewWithTag:14];
        UIButton *button20 = (UIButton *)[_emojiView viewWithTag:20];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.contentMode = UIViewContentModeScaleAspectFit;
        [back setImage:[UIImage imageNamed:@"chat_btn_facedel"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        [_emojiView addSubview:back];
        
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(button14);
            make.centerY.mas_equalTo(button20);
        }];
    }
    return _emojiView;
}

- (void) backFace {
    NSString *inputString = _chatTextField.text;
    if ( [inputString length] > 0) {
        NSString *string = nil;
        NSInteger stringLength = [inputString length];
        if (stringLength >= FACE_NAME_LEN) {
            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
            if ( range.location == 0 ) {
                string = [inputString substringToIndex:[inputString rangeOfString:FACE_NAME_HEAD options:NSBackwardsSearch].location];
            } else {
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else {
            string = [inputString substringToIndex:stringLength - 1];
        }
        _chatTextField.text = string;
    }
}

- (void)faceButtonClicked:(id)sender {
    NSInteger i = ((UIButton*)sender).tag;
    
    NSMutableString *faceString = [[NSMutableString alloc]initWithString:_chatTextField.text];
    [faceString appendString:[NSString stringWithFormat:@"[em2_%02d]",(int)i]];
    _chatTextField.text = faceString;
    
    [self chatTextFieldChange];
}

-(void)DoubleTap:(UITapGestureRecognizer*)sender {
    NSLog(@"---双击");
    CGPoint point = [sender locationInView:self.view];
    
    if([self.chatTextField isFirstResponder] || (_ccPrivateChatView && _ccPrivateChatView.frame.origin.y < self.view.frame.size.height - 50 && !CGRectContainsPoint(_ccPrivateChatView.frame,point))) {
        [_chatTextField resignFirstResponder];
        [_ccPrivateChatView.privateChatViewForOne.chatTextField resignFirstResponder];
        WS(ws)
        
        [ws.ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(542));
            make.bottom.mas_equalTo(ws.view).offset(CCGetRealFromPt(542));
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [ws.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [ws.ccPrivateChatView showTableView];
            if(ws.ccPrivateChatView.privateChatViewForOne) {
                [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
                ws.ccPrivateChatView.privateChatViewForOne = nil;
            }
        }];
    } else if((_ccPrivateChatView && _ccPrivateChatView.frame.origin.y < self.view.frame.size.height - 50 && CGRectContainsPoint(_ccPrivateChatView.frame,point))){
        
    } else if (CGRectContainsPoint(_contentBtnView.frame,point)){
        
    } else {
        _isCameraFront = !_isCameraFront;
        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraFront:_isCameraFront];
        
        if (self.selectedPhotos.count > 0)
        {
            UIImage *image = self.currentShowImage;
            [[CCPushUtil sharedInstanceWithDelegate:self] publishImage:image isBig:_isBig];
        }
    }
}

-(void)publishPicBtnClicked {
    if((_publishPicBtn.selected && self.selectedPhotos!= nil) || (!_publishPicBtn.selected && self.selectedPhotos== nil)) return;
    
    _publishPicBtn.selected = !_publishPicBtn.selected;
    if(_publishPicBtn.selected) {
        CGImageRelease(self.currentShowImage.CGImage);
        self.currentShowImageIndex = 0;
        [self.selectedPhotos removeAllObjects];
        self.selectedPhotos = nil;
        _isBig = YES;
        [self updateDetailLabel];
        [[CCPushUtil sharedInstanceWithDelegate:self] clearPublishImage];
    } else {
        self.selectedPhotos = [NSMutableArray array];
        _ipc = [AGImagePickerController sharedInstance:self];
        
        __weak PushViewController *blockSelf = self;
        _ipc.didFailBlock = ^(NSError *error) {
            if (error == nil) {
                [blockSelf.selectedPhotos removeAllObjects];
                [blockSelf dismissViewControllerAnimated:YES completion:NULL];
            } else {
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [blockSelf dismissViewControllerAnimated:YES completion:NULL];
                });
            }
            
            blockSelf.publishPicBtn.selected = YES;
            [blockSelf.selectedPhotos removeAllObjects];
            blockSelf.selectedPhotos = nil;
            blockSelf.currentShowImageIndex = 0;
            blockSelf.isBig = YES;
            [blockSelf updateDetailLabel];

            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        };
        _ipc.didFinishBlock = ^(NSArray *info) {
            [blockSelf.selectedPhotos setArray:info];
            [blockSelf dismissViewControllerAnimated:YES completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    ALAsset *asset = blockSelf.selectedPhotos.firstObject;
                    ALAssetRepresentation *rep = asset.defaultRepresentation;
                    CGImageRef imageRef = rep.fullScreenImage;
                    UIImage *iamge = [UIImage imageWithCGImage:imageRef];
                    blockSelf.currentShowImageIndex = 1;
                    blockSelf.currentShowImage = iamge;
                    [blockSelf updateDetailLabel];
                    [[CCPushUtil sharedInstanceWithDelegate:blockSelf] publishImage:iamge  isBig:blockSelf.isBig];
                });
            }];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        };

        _ipc.shouldShowSavedPhotosOnTop = NO;
        _ipc.shouldChangeStatusBarStyle = YES;
        _ipc.selection = self.selectedPhotos;
        _ipc.maximumNumberOfPhotosToBeSelected = 9;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:_ipc animated:YES completion:NULL];
            [_ipc showFirstAssetsController];
        });
    }
}

-(void)handleSwipeFromRight:(UISwipeGestureRecognizer *)recognizer {
    if (self.currentShowImageIndex <= 1)
    {
        return;
    }
    self.currentShowImageIndex--;
    ALAsset *asset = [self.selectedPhotos objectAtIndex:self.currentShowImageIndex - 1];
    ALAssetRepresentation *rep = asset.defaultRepresentation;
    CGImageRef imageRef = rep.fullScreenImage;
    UIImage *iamge = [UIImage imageWithCGImage:imageRef];
    self.currentShowImage = iamge;
    [[CCPushUtil sharedInstanceWithDelegate:self] publishImage:iamge isBig:_isBig];
    [self updateDetailLabel];
}

-(void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)recognizer {
    if (self.currentShowImageIndex >= self.selectedPhotos.count)
    {
        return;
    }
    self.currentShowImageIndex++;
    ALAsset *asset = [self.selectedPhotos objectAtIndex:self.currentShowImageIndex - 1];
    ALAssetRepresentation *rep = asset.defaultRepresentation;
    CGImageRef imageRef = rep.fullScreenImage;
    UIImage *iamge = [UIImage imageWithCGImage:imageRef];
    self.currentShowImage = iamge;
    [[CCPushUtil sharedInstanceWithDelegate:self] publishImage:iamge isBig:_isBig];
    [self updateDetailLabel];
}

- (void)updateDetailLabel
{
    NSString *detail = nil;
    if(self.currentShowImageIndex == 0) {
        detail = @"";
    } else {
        detail = [NSString stringWithFormat:@"%d/%lu", self.currentShowImageIndex, (unsigned long)self.selectedPhotos.count];
    }
    self.detailLabel.text = detail;
    [self.detailLabel sizeToFit];
}

#pragma mark - AGImagePickerControllerDelegate methods

- (NSUInteger)agImagePickerController:(AGImagePickerController *)picker
         numberOfItemsPerRowForDevice:(AGDeviceType)deviceType
              andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (deviceType == AGDeviceTypeiPad)
    {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            return 11;
        else
            return 8;
    } else {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            if (480 == self.view.bounds.size.width) {
                return 6;
            }
            return 7;
        } else
            return 4;
    }
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldDisplaySelectionInformationInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldShowToolbarForManagingTheSelectionInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);
}

-(AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionModeForAGImagePickerController:(AGImagePickerController *)picker
{
    return AGImagePickerControllerSelectionBehaviorTypeRadio;
}

- (void)SingleTap:(UIPinchGestureRecognizer *)sender
{
    NSLog(@"---单击");
    CGPoint point = [sender locationInView:self.view];
    [[CCPushUtil sharedInstanceWithDelegate:self] focuxAtPoint:point];
    
    CGRect smallRect = CGRectMake(0,0,self.view.frame.size.width / 4,self.view.frame.size.height / 4); ;
    
    if([self.chatTextField isFirstResponder] || (_ccPrivateChatView && _ccPrivateChatView.frame.origin.y < self.view.frame.size.height - 50 && !CGRectContainsPoint(_ccPrivateChatView.frame,point))) {
        [_chatTextField resignFirstResponder];
        [_ccPrivateChatView.privateChatViewForOne.chatTextField resignFirstResponder];
        WS(ws)
        
        [ws.ccPrivateChatView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(542));
            make.bottom.mas_equalTo(ws.view).offset(CCGetRealFromPt(542));
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [ws.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [ws.ccPrivateChatView showTableView];
            if(ws.ccPrivateChatView.privateChatViewForOne) {
                [ws.ccPrivateChatView.privateChatViewForOne removeFromSuperview];
                ws.ccPrivateChatView.privateChatViewForOne = nil;
            }
        }];
    } else if(CGRectContainsPoint(smallRect,point) && self.currentShowImageIndex != 0) {
        _isBig = !_isBig;
        UIImage *image = self.currentShowImage;
        [[CCPushUtil sharedInstanceWithDelegate:self] publishImage:image isBig:_isBig];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if(self.isScreenLandScape) {
        bool bRet = ((toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft));
        return bRet;
    }else{
        return false;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if(self.isScreenLandScape){
        return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end


