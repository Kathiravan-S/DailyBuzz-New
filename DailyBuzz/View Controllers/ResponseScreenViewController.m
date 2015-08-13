//
//  ResponseScreenViewController.m
//  DailyBuzz
//
//  Created by Kathir on 8/11/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import "ResponseScreenViewController.h"
#import "SharedManager.h"
#import "UtilityManager.h"
#import "ArticleDetailViewController.h"

@interface ResponseScreenViewController ()

@property (nonatomic, weak) IBOutlet UIView *pointsView;
@property (nonatomic, weak) IBOutlet UILabel *pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalPointsLabel;

@property (nonatomic, weak) IBOutlet UIImageView *articleImageView;
@property (nonatomic, weak) IBOutlet UILabel *articleTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *standFirstLabel;

@property (nonatomic, weak) NSDictionary *articleDictionary;
@property (nonatomic) NSInteger pointsEarned;

- (IBAction)didSelectReadArticle:(id)sender;
- (IBAction)didSelectNextQuestion:(id)sender;

@end


@implementation ResponseScreenViewController


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
    
    self.pointsView.layer.cornerRadius = self.pointsView.bounds.size.width / 2.0;
    self.pointsView.layer.borderWidth = 2.0;
    self.pointsView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self updateContents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark -
#pragma mark Private Methods

- (void)loadContentsWithDictionary:(NSDictionary *)tempDictionary withPoints:(NSInteger)points {
    self.articleDictionary = tempDictionary;
    self.pointsEarned = points;
}

// Load Article details in View
- (void)updateContents {
    NSString *pointsString = @"";
    if (self.pointsEarned <= 0) {
        self.pointsEarned = 0;
        pointsString = @"NO POINTS FOR YOU!";
    }
    else if (self.pointsEarned == 1) {
        pointsString = [NSString stringWithFormat:@"+%ld POINT FOR YOU!", (long)self.pointsEarned];
    }
    else {
        pointsString = [NSString stringWithFormat:@"+%ld POINTS FOR YOU!", (long)self.pointsEarned];
    }
    self.pointsLabel.text = pointsString;
    
    // Cache points
    NSInteger totalPoints = [[SharedManager sharedManager] totalPoints] + self.pointsEarned;
    [[SharedManager sharedManager] setTotalPoints:totalPoints];
    
    // Store points in user defaults. We can get total points again when app killed in background and launches from home
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:totalPoints] forKey:@"TotalPoints"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.totalPointsLabel.text = [NSString stringWithFormat:@"TOTAL POINTS %ld", (long)totalPoints];
    
    // Get image from cache.
    NSString *imageURLString = [self.articleDictionary objectForKey:@"imageUrl"];
    UIImage *originalImage = [[[SharedManager sharedManager] imageCacheDictionary] objectForKey:imageURLString];
    UIImage *image = [UtilityManager resizeImageWithImage:originalImage withSize:self.articleImageView.bounds];
    self.articleImageView.image = image;
    
    NSArray *headlinesArray = [self.articleDictionary objectForKey:@"headlines"];
    
    NSInteger titleIndex = [[self.articleDictionary objectForKey:@"correctAnswerIndex"] integerValue];
    
    if ([headlinesArray count] > titleIndex) {
        self.articleTitleLabel.text = [headlinesArray objectAtIndex:titleIndex];
    }
    
    self.standFirstLabel.text = [self.articleDictionary objectForKey:@"standFirst"];
}


#pragma mark -
#pragma mark Button Action Methods

// To show article detail page
- (IBAction)didSelectReadArticle:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ArticleDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"ArticleDetailViewController"];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController loadArticleWithUrl:[self.articleDictionary objectForKey:@"storyUrl"]];
}

// Navigate to Question screen
- (IBAction)didSelectNextQuestion:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectNextQuestion)]) {
        [self.delegate didSelectNextQuestion];
    }
}

@end
