//
//  Person.h
//  KVOExplore
//
//  Created by nucarf on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, assign) NSInteger age;

@end

NS_ASSUME_NONNULL_END
