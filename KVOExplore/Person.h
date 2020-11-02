//
//  Person.h
//  KVOExplore
//
//  Created by nucarf on 2020/10/30.
//

#import <Foundation/Foundation.h>
#import "NSObject+KVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, strong) NSMutableArray *dataArray;

// 下载进度 总进度
@property (nonatomic, assign) NSInteger totalData;
// 下载进度
@property (nonatomic, assign) NSInteger writeData;
@property (nonatomic, strong) NSString *downloadProgress;

@end

NS_ASSUME_NONNULL_END
