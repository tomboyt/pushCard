//
//  CalendarTool.m
//  PunchCard
//
//  Created by 唐全 on 2021/4/23.
//

#import "CalendarTool.h"
#import <EventKit/EventKit.h>
#import <UIKit/UIKit.h>
#import "Tool.h"

@interface CalendarTool()
@property (nonatomic, strong)  EKEventStore *shareStore;
@end
@implementation CalendarTool

static CalendarTool *_shareInstance = nil;
 
+ (instancetype)shareInstance;
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _shareInstance = [[CalendarTool alloc] init];
        
    });
    return _shareInstance;
}
 
 

- (void)saveEventByCourse:(CalendarModel *)CalendarModel block:(void(^)(BOOL isSuccesed))block
{
    [self saveEventByCourseWithId:CalendarModel.detailtime WithName:CalendarModel.show_name block:^(BOOL isSuccesed) {
        block(YES);
    }];
    //[self saveEventByCourseWithId:course_M.course_id WithName:course_M.course_name block:block];
    
}
 
- (void)saveEventByCourseWithId:(NSString *)time_id WithName:(NSString *)show_name block:(void(^)(BOOL isSuccesed))block
{
    [self shareStore];
    [_shareStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                //错误细心
                // display error message here
                block(NO);
            }
            else if (!granted)
            {
                //被用户拒绝，不允许访问日历
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户被拒绝访问日历" message:@"请在设置中修改APP访问权限" delegate:nil cancelButtonTitle:@"oky!" otherButtonTitles:nil];
                [alert show];
#pragma clang diagnostic pop
                block(NO);
            }
            else
            {
                // access granted
                // ***** do the important stuff here *****
                //事件保存到日历
                //创建事件
                EKEvent *event  = [EKEvent eventWithEventStore:self.shareStore];
                event.title     = show_name;
                event.location = @"位置:公司";//@"打卡完成";
                event.notes = @"点击URL调转到相应界面";
                event.URL = [NSURL URLWithString:[NSString stringWithFormat:@""]];
                NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                event.startDate = [[NSDate alloc] init];
                event.endDate   = [[NSDate alloc] init];
                event.allDay = NO;
                //添加提醒
                [event addAlarm:[EKAlarm alarmWithRelativeOffset:1]];
                //[event addAlarm:[EKAlarm alarmWithRelativeOffset:60]];
                [event setCalendar:[self.shareStore defaultCalendarForNewEvents]];
                
                NSError *err;
                [self.shareStore saveEvent:event span:EKSpanThisEvent error:&err];
                NSLog(@"event id = %@",event.eventIdentifier);
                
                
                NSString *keys = [NSString stringWithFormat:@"%@_%@",[Tool getUUID],time_id];
                [[NSUserDefaults standardUserDefaults] setObject:event.eventIdentifier forKey:keys];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Event Created" message:@"Yay!?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
#pragma clang diagnostic pop
                NSLog(@"保存成功");
                block(YES);
            }
        });
    }];
 
}


- (void)deleteEventByCourse:(CalendarModel *)CalendarModel block:(void(^)(BOOL isSuccesed))block
{
    [self deleteEventByCourseWithId:CalendarModel.detailtime block:block];
}
 
- (void)deleteEventByCourseWithId:(NSString *)time_id block:(void(^)(BOOL isSuccesed))block
{
    [self shareStore];
    // the selector is available, so we must be on iOS 6 or newer
    [_shareStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                //错误细心
                block(NO);
            }
            else if (!granted)
            {
                //被用户拒绝，不允许访问日历
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户被拒绝访问日历" message:@"请在设置中修改APP访问权限" delegate:nil cancelButtonTitle:@"oky!" otherButtonTitles:nil];
                [alert show];
#pragma clang diagnostic pop
                block(NO);
            }
            else
            {
                // access granted
                // ***** do the important stuff here *****
                //事件保存到日历
                //创建事件
                NSString *eventID = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",[Tool getUUID],time_id]];
                EKEvent *event  = [self.shareStore eventWithIdentifier:eventID];
                if(event)
                {
                    NSError *err;
                    [self.shareStore removeEvent:event span:EKSpanThisEvent error:&err];
                    NSLog(@"删除成功");
                    block(YES);
                }else
                {
                    block(NO);
                }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Event Created" message:event?@"Yay!?":@"NO!?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
#pragma clang diagnostic pop
            }
        });
    }];
}


- (void)isEventByBourse:(CalendarModel *)CalendarModel block:(void(^)(BOOL isExsit))block
{
    [self isEventByBourseWithId:CalendarModel.times_id block:block];
 }
 
- (void)isEventByBourseWithId:(NSString *)time_id block:(void(^)(BOOL isExsit))block
{
    [self shareStore];
    __block BOOL isExit;
    // the selector is available, so we must be on iOS 6 or newer
    [_shareStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                //错误细心
                // display error message here
                block(NO);
            }
            else if (!granted)
            {
                //被用户拒绝，不允许访问日历
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户被拒绝访问日历" message:@"请在设置中修改APP访问权限" delegate:nil cancelButtonTitle:@"oky!" otherButtonTitles:nil];
                [alert show];
#pragma clang diagnostic pop
                block(NO);
            }
            else
            {
                // access granted
                // ***** do the important stuff here *****
                //事件保存到日历
                //创建事件
                NSString *keys = [NSString stringWithFormat:@"%@_%@",[Tool getUUID],time_id];
                NSString *eventID = [[NSUserDefaults standardUserDefaults] objectForKey:keys];
                EKEvent *event  = [self.shareStore eventWithIdentifier:eventID];
                if(event)
                {
                    isExit = YES;
                    block(YES);
                }else
                {
                    block(NO);
                }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Event Created" message:event?@"Yay!?":@"NO!?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
#pragma clang diagnostic pop
            }
        });
    }];
}
 
#pragma mark init
- (EKEventStore *)shareStore
{
    if(!_shareStore)
    {
        _shareStore = [[EKEventStore alloc] init];
    }
    return _shareStore;
}
@end
