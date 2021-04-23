//
//  DBTool.h
//  PunchCard
//
//  Created by 唐全 on 2021/4/23.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBTool : NSObject
@property (strong, nonatomic) FMDatabase *db;

+ (instancetype)shareInstance;

//创建数据库
- (void)CreateChart:(NSString *)createStatement;


/// 根据时间查询数据
/// @param chartnameStr 表名
/// @param timeStr 打卡时间
- (NSArray*)sqChart:(NSString*)chartnameStr byCalendarTime:(NSString*)timeStr;


/// 根据表名查找表中的数据
/// @param chartName 表名
- (NSArray *)sqChart:(NSString*)chartName;

/// 插入数据
/// @param chartnameStr 表名
/// @param timeArr 打卡时间
- (void)insertChart:(NSString*)chartnameStr byCalendarTime:(NSArray*)timeArr andcontinuedays:(NSString*)continuedays;


/// 删除数据
/// @param chartnameStr 表名
/// @param timeArr 打卡时间
- (void)deletedatafromeChart:(NSString *)chartnameStr byCalendarTime:(NSArray*)timeArr;
@end

NS_ASSUME_NONNULL_END
