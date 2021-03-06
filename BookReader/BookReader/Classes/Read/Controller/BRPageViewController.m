//
//  BRPageViewController.m
//  BookReader
//
//  Created by joe on 2017/5/18.
//  Copyright © 2017年 joe. All rights reserved.
//
#define kOperationDefaultViewNTPageViewControllerPage @"kOperationDefaultViewNTPageViewControllerPage"
#define kBRSearchMainViewNFKey @"kBRSearchMainViewNFKey"

#import "BRPageViewController.h"
#import "ContentViewController.h"
#import "BRBookModel.h"
@interface BRPageViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

@end

@implementation BRPageViewController
#pragma mark - life cycle
- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options
{
    if (self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options]) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIGestureRecognizer *ges in self.view.gestureRecognizers) {
        ges.delegate = self;
    }
    
    /** 滑动进度条的通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageToIndex:) name:kOperationDefaultViewNTPageViewControllerPage object:nil];
    /** 点击搜索结果cell的通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchResult:) name:kBRSearchMainViewNFKey object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - delegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexWithViewController:(ContentViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法,自动来维护次序
    // 不用我们去操心每个ViewController的顺序问题
    // 改变model读书记录
    self.model.recordPageNum = index;
    // 将model缓存
    return [self viewControllerWithIndex:index];
}

/** 拿到下一个controller */
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexWithViewController:(ContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.model.pageModelArray count]) {
        return nil;
    }
    //改变model总的读书记录
    self.model.recordPageNum = index;
    //将model缓存
    
    return [self viewControllerWithIndex:index];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //Touch gestures below top bar should not make the page turn.
    //EDITED Check for only Tap here instead.
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (touchPoint.y > 40) {
            return NO;
        }
        else if (touchPoint.x > 50 && touchPoint.x < 430) {//Let the buttons in the middle of the top bar receive the touch
            return NO;
        }
    }
    return YES;
}
#pragma mark - event response
#pragma mark - private methods
/** 通过下标获取controller */
- (ContentViewController *)viewControllerWithIndex:(NSUInteger)index {
    if (self.model.pageModelArray.count == 0 || (index > self.model.pageModelArray.count)) {
        return nil;
    }
    ContentViewController *vc = [[ContentViewController alloc] init];
    vc.model = self.model.pageModelArray[index];
    return vc;
}
#pragma mark - 通过controller获取下标
- (NSUInteger)indexWithViewController:(ContentViewController *)viewController {
    return [self.model.pageModelArray indexOfObject:viewController.model];
}
/** 通过下标跳转相应的页面 */
- (void)pushToPage:(NSUInteger)index
{
    ContentViewController *vc = [self viewControllerWithIndex:index];
    
    NSArray *vcs = [NSArray arrayWithObject:vc];
    [self setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    self.model.recordPageNum = index;
}
/** 通知回调 */
- (void)pageToIndex:(NSNotification *)notification
{
    NSInteger tmpIndex = [notification.userInfo[@"pageNum"] integerValue];
    NSUInteger index = tmpIndex == 0 ? 0 : tmpIndex - 1;
    [self pushToPage:index];
}
/** 点击搜索结果cell的通知 */
- (void)searchResult:(NSNotification *)notification
{
    NSUInteger index = [notification.userInfo[@"pageNum"] integerValue];
    
    [self pushToPage:index];
}
#pragma mark - getters and setters

- (void)setModel:(BRBookModel *)model
{
    _model = model;
    
    //展示页面
    
    [self pushToPage:model.recordPageNum];
}



@end
