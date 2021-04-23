//
//  Tool.h
//  PunchCard
//
//  Created by 唐全 on 2021/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,dayis) {
    dayis_last = 0,
    dayis_now,
    dayis_next
};
@interface Tool : NSObject

//获取当前时间戳有两种方法(以秒为单位)
+(NSString *)getNowTimeTimestamp;

/// 时间戳转时间字符串
/// @param timestamp 时间戳
+(NSString *)timestampSwitchTime:(NSString*)timestamp;

//获取时间（其一天当天后一天前一天的ymd）
+(NSString *)getDate:(dayis)days;

//获取UUID
+ (NSString *)getUUID;
@end

NS_ASSUME_NONNULL_END
