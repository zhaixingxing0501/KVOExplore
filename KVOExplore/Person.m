//
//  Person.m
//  KVOExplore
//
//  Created by nucarf on 2020/10/30.
//

#import "Person.h"
#define NSLog(fmt, ...) fprintf(stderr, "\n%s", [[NSString stringWithFormat:fmt, ## __VA_ARGS__] UTF8String])

@implementation Person

//// 关闭自动建值观察者
//+ (BOOL)accessInstanceVariablesDirectly:(NSString *)key {
//    return NO;
//}
//
//- (void)setName:(NSString *)name {
//    [self willChangeValueForKey:name];
//    NSLog(@"setter方法: willChangeValueForKey -%@", _name);
//    _name = [name copy];
//    [self didChangeValueForKey:name];
//    NSLog(@"setter方法: didChangeValueForKey -%@", _name);
//}

- (NSString *)downloadProgress {
    return [NSString stringWithFormat:@"%f", 1.0f * self.writeData / self.totalData];
}

// 路径处理
+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
    if ([key isEqualToString:@"downloadProgress"]) {
        NSArray *affectingKey = @[@"totalData", @"writeData"];
        [keyPaths setByAddingObjectsFromArray:affectingKey];
    }
    return keyPaths;
}

@end
