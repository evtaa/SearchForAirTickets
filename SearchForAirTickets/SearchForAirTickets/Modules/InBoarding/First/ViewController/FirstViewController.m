//
//  FirstViewController.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 25.03.2021.
//

#import "FirstViewController.h"
#import "ContentViewController.h"
#import "NSString+Localize.h"

#define CONTENT_COUNT 4

@interface FirstViewController ()
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation FirstViewController {
    struct firstContentData {
        __unsafe_unretained NSString *title;
        __unsafe_unretained NSString *contentText;
        __unsafe_unretained NSString *imageName;
    } contentData[CONTENT_COUNT];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [self createContentDataArray];
    
    self.dataSource = self;
    self.delegate = self;
    
    ContentViewController *startViewController = [self viewControllerAtIndex:0];
    [self setViewControllers:@[startViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - Config

- (void) config {
    [self configView];
    [self configPageControl];
    [self configNextButton];
}

- (void) configView {
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) configPageControl {
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50.0, self.view.bounds.size.width, 50.0)];
    self.pageControl.numberOfPages = CONTENT_COUNT;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    [self.view addSubview: self.pageControl];
}

- (void) configNextButton {
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextButton.frame = CGRectMake(self.view.bounds.size.width - 100.0, self.view.bounds.size.height - 50.0, 100.0, 50.0);
    [self.nextButton addTarget:self action:@selector(nextButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setTintColor:[UIColor blackColor]];
    [self updateButtonWithIndex:0];
    [self.view addSubview: self.nextButton];
}

#pragma mark - Private

- (void) createContentDataArray {
    NSArray *titles = [NSArray arrayWithObjects:[@"about_app_header" localize], [@"tickets_header" localize], [@"map_price_header" localize], [@"favorites_header" localize], nil];
    NSArray *contents = [NSArray arrayWithObjects:[@"about_app_describe" localize], [@"tickets_describe" localize], [@"map_price_describe" localize], [@"favorites_describe" localize], nil];
    for (int i = 0; i < 4; ++i) {
        contentData[i].title = [titles objectAtIndex:i];
        contentData[i].contentText = [contents objectAtIndex:i];
        contentData[i].imageName = [NSString stringWithFormat:@"first_%d", i+1];
    }
}

- (ContentViewController *)viewControllerAtIndex:(int)index {
    if (index < 0 || index >= CONTENT_COUNT) {
        return nil;
    }
    ContentViewController *contentViewController = [[ContentViewController alloc] init];
    contentViewController.title = contentData[index].title;
    contentViewController.contentText = contentData[index].contentText;
    contentViewController.image =  [UIImage imageNamed: contentData[index].imageName];
    contentViewController.index = index;
    return contentViewController;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        int index = ((ContentViewController *)[pageViewController.viewControllers firstObject]).index;
        self.pageControl.currentPage = index;
        [self updateButtonWithIndex:index];
    }
}

- (void)updateButtonWithIndex:(int)index {
    switch (index) {
        case 0:
        case 1:
        case 2:
            [_nextButton setTitle:[@"next_button" localize] forState:UIControlStateNormal];
            _nextButton.tag = 0;
            break;
        case 3:;
            [_nextButton setTitle:[@"done_button" localize] forState:UIControlStateNormal];
            _nextButton.tag = 1;
            break;
        default:
            break;
    }
}

#pragma mark - Action of a button

- (void)nextButtonDidTap:(UIButton *)sender
{
    int index = ((ContentViewController *)[self.viewControllers firstObject]).index;
    if (sender.tag) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"first_start"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        [self setViewControllers:@[[self viewControllerAtIndex:index+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            weakSelf.pageControl.currentPage = index+1;
            [weakSelf updateButtonWithIndex:index+1];
        }];
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = ((ContentViewController *)viewController).index;
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int index = ((ContentViewController *)viewController).index;
    index++;
    return [self viewControllerAtIndex:index];
}

@end
