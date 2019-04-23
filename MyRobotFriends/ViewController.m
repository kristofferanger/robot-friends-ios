//
//  ViewController.m
//  MyRobotFriends
//
//  Created by Kristoffer Anger on 2018-03-24.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import "ViewController.h"
#import "APIHelpers.h"
#import "DetailsViewController.h"
#import "MBProgressHUD.h"

#define DEFAULT_ROW_HEIGHT 50.0
#define NUMBER_OF_FRIENDS 1000

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *robotFriends;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation ViewController

#pragma mark - getters / setters

- (NSArray *)robotFriends {
    
    if (_robotFriends == nil) {
        _robotFriends = [NSArray new];
    }
    return _robotFriends;
}

- (NSCache *)imageCache {
    if (_imageCache == nil) {
        _imageCache = [NSCache new];
    }
    return _imageCache;
}

#pragma mark - init methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set title
    self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];

    // add table
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    [self.view addSubview:self.tableView];
    
    // show loading indicator
    MBProgressHUD *progressIndicator = [MBProgressHUD new];
    progressIndicator.labelText = @"Laddar...";
    [self.view addSubview:progressIndicator];
    [progressIndicator show:YES];
    
    // download friends
    [APIHelpers makeRequestWithResource:@"/users.json" parameters:@{} completion:^(NSDictionary *response) {

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSArray *result = [response objectForKey:@"result"];
        if (result) {
            self.robotFriends = result;
            [self.tableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    if (selectedRow) {
        [self.tableView deselectRowAtIndexPath:selectedRow animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    [self.imageCache removeAllObjects];
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.robotFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"robot_friend_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    // get friends data
    NSDictionary *robotFriendData = [self.robotFriends objectAtIndex:indexPath.row];
    
    // add name
    NSString *fullName = [[NSArray arrayWithObjects:[robotFriendData objectForKey:@"first_name"], [robotFriendData objectForKey:@"last_name"], nil]componentsJoinedByString:@" "];
    cell.textLabel.text = fullName;
    
    // add email
    cell.detailTextLabel.text = [robotFriendData objectForKey:@"email"];
    
    // add avatar image
    NSString *avatarImageUrl = [robotFriendData objectForKey:@"image"];
    [self addImageWithUrl:avatarImageUrl toImageView:cell.imageView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get friends data
    NSDictionary *robotFriendData = [self.robotFriends objectAtIndex:indexPath.row];

    // push details
    DetailsViewController *detailsViewController = [[DetailsViewController alloc]initWithFriendData:robotFriendData];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

#pragma mark - NSURLSession methods

- (void)addImageWithUrl:(NSString *)urlString toImageView:(UIImageView *)imageView {
    
    // cancel any already ongoing task
    if (imageView.tag > 0) {
        [self cancelTaskByIdentifer:imageView.tag];
    }
    
    // use cached image or start download
    UIImage *cachedImage = [self.imageCache objectForKey:urlString];
    
    if (cachedImage) {
        imageView.image = cachedImage;
    }
    else {
        imageView.image = [UIImage imageNamed:@"placeholder_image"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data , NSURLResponse *urlResponse, NSError *error) {
            
            if (data) {
                // cache image
                UIImage *downloadImage = [UIImage imageWithData:data];
                [self.imageCache setObject:downloadImage forKey:urlString];

                // add image view on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // reset tag
                    imageView.tag = 0;

                    if (imageView.window) {
                        imageView.image = downloadImage;
                    }
                });
            }
        }];
        // add task identifier to view
        // to be able to cancel task
        imageView.tag = dataTask.taskIdentifier;
        [dataTask resume];
    }
}


- (void)cancelTaskByIdentifer:(NSUInteger)taskIdentifier {
    
    [[NSURLSession sharedSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (!dataTasks || !dataTasks.count) {
            return;
        }
        for (NSURLSessionTask *task in dataTasks) {
            if (task.taskIdentifier == taskIdentifier) {
                [task cancel];
            }
        }
    }];
}

@end
