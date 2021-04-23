//
//  CalendarTool.h
//  PunchCard
//
//  Created by 唐全 on 2021/4/23.
//

#import <Foundation/Foundation.h>
#import "CalendarModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CalendarTool : NSObject
+ (instancetype)shareInstance;
 
//根据名字存入日历
- (void)saveEventByCourse:(CalendarModel *)CalendarModel block:(void(^)(BOOL isSuccesed))block;
//根据打卡时间存入日历
- (void)saveEventByCourseWithId:(NSString *)time_id WithName:(NSString *)show_name block:(void(^)(BOOL isSuccesed))block;
//根据名字删除日历
- (void)deleteEventByCourse:(CalendarModel *)CalendarModel block:(void(^)(BOOL isSuccesed))block;
//根据打卡时间删除日历
- (void)deleteEventByCourseWithId:(NSString *)time_id block:(void(^)(BOOL isSuccesed))block;
//根据名字查看是否在日历中存在
- (void)isEventByBourse:(CalendarModel *)CalendarModel block:(void(^)(BOOL isExsit))block;
//根据打卡时间查看否在日历中存在
- (void)isEventByBourseWithId:(NSString *)time_id block:(void(^)(BOOL isExsit))block;
@end

NS_ASSUME_NONNULL_END
