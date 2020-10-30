//
//  ViewController.m
//  KVOExplore
//
//  Created by nucarf on 2020/10/30.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Person.h"

#define NSLog(fmt, ...) fprintf(stderr, "\n%s", [[NSString stringWithFormat:fmt, ## __VA_ARGS__] UTF8String])

@interface ViewController ()

@property (nonatomic, strong) Person *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.person = [Person new];
    //context:(nullable void *) void * 类型 用NULL
    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];

    self.person.name = @"+";
}



- (IBAction)modifiedValue:(UIButton *)sender {
    self.person.name = [NSString stringWithFormat:@"%@+", self.person.name];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"监听方法:%@", change);
}

- (IBAction)removeObserve:(UIButton *)sender {
    [self.person removeObserver:self forKeyPath:@"name"];
    NSLog(@"观察者移除成功");
}

- (void)dealloc {
    [self.person removeObserver:self forKeyPath:@"name"];
}

@end
