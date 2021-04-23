//
//  ViewController.m
//  PunchCard
//
//  Created by 唐全 on 2021/4/23.
//

#import "ViewController.h"
#import "CalendarTool.h"
#import "CalendarModel.h"
#import "DBTool.h"
#import "Tool.h"

@interface ViewController ()
@property (nonatomic, strong)UILabel *totalLab;
@property (nonatomic, strong)UILabel *continuouspunchingLab;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *UIArr = [NSMutableArray array];
    UIButton *SaveBtn = [[UIButton alloc]init];
    [SaveBtn setTitle:@"打卡" forState:UIControlStateNormal];
    SaveBtn.tag = NO;
    
    UIButton *seeBtn = [[UIButton alloc]init];
    [seeBtn setTitle:[NSString stringWithFormat:@"%@当天打卡数据",[Tool getDate:dayis_now]] forState:UIControlStateNormal];
    seeBtn.tag = FP_NAN;
    
    UIButton *seebyNameBtn = [[UIButton alloc]init];
    [seebyNameBtn setTitle:@"name查看" forState:UIControlStateNormal];
    seebyNameBtn.tag = FP_INFINITE;
    seebyNameBtn.hidden = YES;
    
    UIButton *deleteBtn = [[UIButton alloc]init];
    [deleteBtn setTitle:@"删除后一次打卡记录，可改变日期删除该日期记录" forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    deleteBtn.tag = FP_ZERO;
    
    _totalLab = [[UILabel alloc]init];
    _totalLab.text = [NSString stringWithFormat:@"共：%ld次",[[DBTool shareInstance] sqChart:@"calendarchart"].count];
    
    _continuouspunchingLab = [[UILabel alloc]init];
    NSArray *datas = [[DBTool shareInstance] sqChart:@"calendarchart"];
    NSString *days=@"0";
    if (datas.count) {
        CalendarModel *lastML = datas.lastObject;
        if ([lastML.times_id isEqualToString:[Tool getDate:dayis_now]]) {
            days = lastML.continuedays;
        }else if([lastML.times_id isEqualToString:[Tool getDate:dayis_last]]){
            days = [NSString stringWithFormat:@"%ld",lastML.continuedays.integerValue+1];
        }else{
            days = @"0";
        }
    }
    _continuouspunchingLab.text = [NSString stringWithFormat:@"连续打卡%@天",days];
    
    [UIArr addObjectsFromArray:@[SaveBtn,seeBtn,seebyNameBtn,deleteBtn,_totalLab,_continuouspunchingLab]];
    for (int i=0;i<UIArr.count;i++) {
        UIView *view = UIArr[i];
        view.backgroundColor = i%2?UIColor.grayColor:UIColor.blueColor;
        view.frame = CGRectMake(15, 100+i*60, UIScreen.mainScreen.bounds.size.width-30, 50);
        
        [self.view addSubview:view];
        if ([UIArr[i] isKindOfClass:[UIButton class]]) {
            UIButton *btn = UIArr[i];
            [btn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    
    //创建表（id，calendartime=打卡时间）
    [[DBTool shareInstance] CreateChart:@"CREATE TABLE IF NOT EXISTS calendarchart (id integer PRIMARY KEY AUTOINCREMENT, calendartime text NOT NULL, detailtime text NOT NULL, continuosusday text NOT NULL);"];
}


#pragma mark - Action

- (void)done:(UIButton*)Btn{
    Btn.enabled = NO;
    NSString *nowTime = [Tool getNowTimeTimestamp];
    switch (Btn.tag) {
        case NO:{//根据时间打卡
            CalendarModel *M = [[CalendarModel alloc]init];
            //获取表中最后一次打卡的连续打卡天数计算本次打卡连续打卡的天数
            NSArray *datas = [[DBTool shareInstance] sqChart:@"calendarchart"];
            if (datas.count) {
                CalendarModel *lastML = datas.lastObject;
                if ([lastML.times_id isEqualToString:[Tool getDate:dayis_now]]) {
                    M.continuedays = lastML.continuedays;
                }else if([lastML.times_id isEqualToString:[Tool getDate:dayis_last]]){
                    M.continuedays = [NSString stringWithFormat:@"%ld",lastML.continuedays.integerValue+FP_NAN];
                }else{
                    M.continuedays = @"1";
                }
            }else{
                M.continuedays = @"1";
            }
            _continuouspunchingLab.text = [NSString stringWithFormat:@"连续打卡%@天",M.continuedays];
            M.times_id = [[Tool timestampSwitchTime:nowTime] componentsSeparatedByString:@" "].firstObject;
            M.detailtime = nowTime;
            M.show_name = @"已打卡";
            [[CalendarTool shareInstance] saveEventByCourse:M block:^(BOOL isSuccesed) {
                if (isSuccesed) {
                    //存入日历
                    [[DBTool shareInstance] insertChart:@"calendarchart" byCalendarTime:@[nowTime] andcontinuedays:M.continuedays];
                    //刷新打卡总次数
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.totalLab.text = [NSString stringWithFormat:@"共：%ld次",[[DBTool shareInstance] sqChart:@"calendarchart"].count];
                    });
                }
            }];
        }
            break;
        case  FP_NAN:{//获取当天的打卡次数，也可以传入任意日期查询该日的打卡次数
            NSArray *calendarArr =
            [[DBTool shareInstance] sqChart:@"calendarchart" byCalendarTime:[Tool getDate:dayis_now]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIAlertView *alter = [[UIAlertView alloc]initWithTitle:[Tool getDate:dayis_now] message:[NSString stringWithFormat:@"共打卡%ld次",calendarArr.count] delegate:nil cancelButtonTitle:@"oky!" otherButtonTitles: nil];
            [alter show];
#pragma clang diagnostic pop
        }
            break;
        case  FP_INFINITE:{//
            [[DBTool shareInstance] sqChart:@"calendarchart"];
        }
            break;
        case FP_ZERO:{//删除数据库里最后一次打卡记录
            CalendarModel *M = [[DBTool shareInstance] sqChart:@"calendarchart"].lastObject;
            [[CalendarTool shareInstance] deleteEventByCourse:M block:^(BOOL isSuccesed) {
                if (isSuccesed) {
                    [[DBTool shareInstance]deletedatafromeChart:@"calendarchart" byCalendarTime:@[M.detailtime]];
                    NSArray *datas = [[DBTool shareInstance] sqChart:@"calendarchart"];
                    self.totalLab.text = [NSString stringWithFormat:@"共：%ld次",datas.count];
                    NSString *continuedays;
                    if (datas.count) {
                        CalendarModel *lastML = datas.lastObject;
                        if ([lastML.times_id isEqualToString:[Tool getDate:dayis_now]]||[lastML.times_id isEqualToString:[Tool getDate:dayis_last]]) {
                            continuedays = lastML.continuedays;
                        }else{
                            continuedays = @"0";
                        }
                    }else{
                        continuedays = @"0";
                    }
                    self.continuouspunchingLab.text = [NSString stringWithFormat:@"连续打卡%@天",continuedays];
                }
            }];
        }
            break;
        default:
            break;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Btn.enabled = YES;
    });
}

/**
 *查询打卡数据
 */
- (void)sqCalendar{
    [[DBTool shareInstance] sqChart:@"calendarchart" byCalendarTime:@""];
}
@end
