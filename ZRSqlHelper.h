//
//  ZRSqllib.h
//  Demo
//
//  Created by Ryan on 16/4/1.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZRSqlHelper : NSObject
/**
 *  单例
 *
 *  @return <#return value description#>
 */
+ (instancetype)shareSqlHelper;

//- (id)initWithDBName:(NSString *)dbname;

/**
 *  关闭数据库
 */
- (void)closeDatabase ;

/**
 *  创建表
 *
 *  @param sql 创建表sql语句
 *
 *  @return 是否创建成功
 */
- (BOOL)createTable:(NSString *)sql;

/**
 *  插入数据
 *
 *  @param sql sql语句
 *
 *  @return 是否插入成功
 */
- (BOOL)insertWithSql:(NSString *)sql ;


/**
 *  更新数据
 *
 *  @param sql sql语句
 *
 *  @return 是否更新成功
 */
- (BOOL)updateWithSql:(NSString *)sql ;

/**
 *  删除数据
 *
 *  @param sql sql语句
 *
 *  @return 是否更新成功
 */
- (BOOL)deleteWithSql:(NSString *)sql;

/**
 *  查询数据
 *
 *  @param sql sql语句
 *
 *  @return 查询结果
 */
- (NSArray *)queryWithSql:(NSString *)sql;
@end
