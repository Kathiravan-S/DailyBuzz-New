//
//  ViewController.m
//  DailyBuzz
//
//  Created by Kathir on 8/11/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import "ViewController.h"
#import "HeadlineContainerView.h"
#import "HeadlineContainerViewDelegate.h"
#import "ResponseScreenViewController.h"
#import "SharedManager.h"
#import "SyncHandler.h"
#import "UtilityManager.h"

#define kContentURL @"https://dl.dropboxusercontent.com/u/30107414/game.json"

#define kReadArticlesKey @"DailyBuzzReadArticles"

@interface ViewController () <HeadlineContainerViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *articleSectionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *articleImageView;
@property (nonatomic, weak) IBOutlet UILabel *pointsLabel;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet HeadlineContainerView *headlineContainerView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSMutableArray *contentsArray;
@property (nonatomic, strong) NSDictionary *articleDictionary;
@property (nonatomic) NSInteger currentIndex;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic) NSInteger points;
@property (nonatomic) BOOL isWrongAnswerSelected;

@property (nonatomic, strong) UINavigationController *responseScreenViewController;

@property (nonatomic) BOOL appLauncFromBackground;

@end


@implementation ViewController


#pragma mark -
#pragma mark Memory Management Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark View Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupNotificationObserver];
    
    self.progressView.layer.borderWidth = 2.0;
    self.progressView.layer.borderColor = [UIColor whiteColor].CGColor;

    self.headlineContainerView.delegate = self;
    
    self.view.userInteractionEnabled = NO;
    self.view.alpha = 0.5;
    
    self.contentsArray = [NSMutableArray array];
    
    [self downloadContents];
}


#pragma mark -
#pragma mark Private Methods

// Download Articles from server.
- (void)downloadContents {
    [self.spinner startAnimating];
    
    // Download content from server
    SyncHandler *syncHandler = [[SyncHandler alloc] init];
    [syncHandler sync:kContentURL completion:^(NSData *responseData, NSError *responseError) {
        if (responseError) {
            // Handle error if fails to download content
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:responseError.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                
                [self.spinner stopAnimating];
            });
        }
        else {
            // Content download success
            NSError *error = nil;
            
            // Parse json
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
            
            [self.contentsArray removeAllObjects];
            [self.contentsArray addObjectsFromArray:[jsonObject objectForKey:@"items"]];
            
            [self removeReadArticles];
            
            // Update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.contentsArray count]) {
                    self.currentIndex = 0;
                    
                    [self loadContents];
                }
                else {
                    self.view.userInteractionEnabled = YES;
                    self.view.alpha = 1.0;
                    [self.spinner stopAnimating];
                }
            });
        }
    }];
}

// Update Article details in View.
- (void)loadContents {
    self.articleDictionary = [self.contentsArray objectAtIndex:self.currentIndex];

    [self downloadImage];
    
    self.articleSectionLabel.text = [self.articleDictionary objectForKey:@"section"];
    
    self.points = 10;
    self.pointsLabel.text = [NSString stringWithFormat:@"+%ld points coming your way!", (long)self.points];
    
    [self.headlineContainerView updateHeadLines:[self.articleDictionary objectForKey:@"headlines"]];
}

// Download headline image.
- (void)downloadImage {
    NSString *imageURLString = [self.articleDictionary objectForKey:@"imageUrl"];
    
    // Check image in cache
    UIImage *tempImage = [[[SharedManager sharedManager] imageCacheDictionary] objectForKey:imageURLString];
    if (tempImage) {
        UIImage *image = [UtilityManager resizeImageWithImage:tempImage withSize:self.articleImageView.bounds];
        
        self.articleImageView.image = image;
    }
    else {
        // Download image if it is not in cache
        SyncHandler *syncHandler = [[SyncHandler alloc] init];
        [syncHandler sync:imageURLString completion:^(NSData *responseData, NSError *responseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *originalImage = [UIImage imageWithData:responseData];
                if (!originalImage) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Image download failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                
                UIImage *image = [UtilityManager resizeImageWithImage:originalImage withSize:self.articleImageView.bounds];
                
                self.articleImageView.image = image;
                
                // Handle image cache
                if (originalImage) {
                    [[[SharedManager sharedManager] imageCacheDictionary] setObject:originalImage forKey:imageURLString];
                }
                
                self.view.userInteractionEnabled = YES;
                self.view.alpha = 1.0;
                [self.spinner stopAnimating];
                
                [self startTimer];
            });
        }];
    }
}

// Start timer
- (void)startTimer {
    // Give 10 seconds to guess the headline
    [self resetTimer];
    
    self.points = 10;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePoints) userInfo:nil repeats:YES];
}

- (void)resetTimer {
    [self.timer invalidate];
    self.timer = nil;
    
    self.counter = 10;
    
    self.isWrongAnswerSelected = NO;
}

// Reduce points when second passes
- (void)updatePoints {
    CGRect tempFrame = self.progressLabel.frame;
    tempFrame.size.width = (self.progressView.bounds.size.width / 10) * self.counter;
    self.progressLabel.frame = tempFrame;
    
    if (self.points >= 0) {
        self.pointsLabel.text = [NSString stringWithFormat:@"+%ld points coming your way!", (long)self.points];
    }
    
    if (self.counter == 0) {
        [self pushToResponseScreen];
    }
    
    self.counter--;
    
    self.points--;
}

// Navigate to response page
- (void)pushToResponseScreen {
    [self resetTimer];
    
    [self markAsRead];
    
    self.appLauncFromBackground = NO;
    
    // Move to response screen when correct answer selected or time expiray
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ResponseScreenViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ResponseScreenViewController"];
    viewController.delegate = self;
    [viewController loadContentsWithDictionary:self.articleDictionary withPoints:self.points];
    
     self.responseScreenViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self addChildViewController:self.responseScreenViewController];
    [self.view addSubview:self.responseScreenViewController.view];
    [self.responseScreenViewController didMoveToParentViewController:self];
    
    // Push animation
    CATransition *transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 0.5;
    
    [self.view.layer addAnimation:transition forKey:@"transition"];
}

// To load Next Question
- (void)removeResponseScreen {
    // Push animation to Question screen
    CATransition *transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 0.5;
    
    [self.responseScreenViewController willMoveToParentViewController:nil];
    [self.responseScreenViewController.view removeFromSuperview];
    [self.responseScreenViewController removeFromParentViewController];
    
    [self.view.layer addAnimation:transition forKey:@"transition"];
    
    [self loadNextArticle];
}

// Load next headline
- (void)loadNextArticle {
    if (self.appLauncFromBackground) {
        self.appLauncFromBackground = NO;
        
        [self removeReadArticles];
        
        if ([self.contentsArray count]) {
            self.currentIndex = 0;
            
            [self loadContents];
        }
    }
    else if ([self.contentsArray count] > self.currentIndex) {
            self.currentIndex += 1;
            
            self.view.userInteractionEnabled = NO;
            self.view.alpha = 0.5;
            [self.spinner startAnimating];
            
            self.progressLabel.frame = self.progressView.bounds;
            
            [self loadContents];
        }
}

// Remove read articles
- (void)removeReadArticles {
    // Filter already read articles from conntent when updated from server.
    NSMutableArray *readArticles = [[NSUserDefaults standardUserDefaults] objectForKey:kReadArticlesKey];
    if (readArticles && [readArticles count]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(imageUrl IN %@)", readArticles];
        NSArray *filteredArray = [self.contentsArray filteredArrayUsingPredicate:predicate];
        
        [self.contentsArray removeObjectsInArray:filteredArray];
    }
}

// Update read articles
- (void)markAsRead {
    // Using imageUrl as primary key to feilter read articles
    NSString *imageURL = [self.articleDictionary objectForKey:@"imageUrl"];
    if (imageURL) {
        NSMutableArray *readArticles = [[NSUserDefaults standardUserDefaults] objectForKey:kReadArticlesKey];
        NSMutableArray *tempArray = [NSMutableArray arrayWithObjects:imageURL, nil];
        if (readArticles && [readArticles count]) {
            [tempArray addObjectsFromArray:readArticles];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:tempArray forKey:kReadArticlesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark -
#pragma mark HeadlineContainerViewDelegate

// Handle headline selection
- (void)didSelectHeadLine:(NSInteger)selectedIndex {
    NSLog(@"Selected Headline Index : %ld", (long)selectedIndex);
    
    NSInteger correctAnswerIndex = [[self.articleDictionary objectForKey:@"correctAnswerIndex"] integerValue];
    
    if (correctAnswerIndex == selectedIndex) {
        [self pushToResponseScreen];
    }
    else if (!self.isWrongAnswerSelected) {
        
        self.points -= 2;
        
        self.isWrongAnswerSelected = YES;
    }
}

- (void)didSelectNextQuestion {
    [self removeResponseScreen];
}


#pragma mark -
#pragma mark Notificatio Methods

- (void)setupNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

// Update Articles when app launches from background
- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.appLauncFromBackground = YES;
    [self downloadContents];
}

@end
