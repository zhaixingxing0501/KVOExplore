//
//  NSObject+KVO.h
//  KVOExplore
//
//  Created by nucarf on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^KVOBlock)(id observer, NSString *keyPath, id oldValue, id newValue);

@interface NSObject (KVO)

- (void)kvo_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(KVOBlock)block;

- (void)kvo_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
