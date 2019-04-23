//
//  DetailsViewController.m
//  MyRobotFriends
//
//  Created by Kristoffer Anger on 2018-03-26.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController () <UIWebViewDelegate>
@property (nonatomic, strong) NSDictionary *detailsFriendData;
@end

@implementation DetailsViewController

- (id)initWithFriendData:(NSDictionary *)friendData {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _detailsFriendData = friendData;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // add background
    self.view.backgroundColor = [UIColor whiteColor];

    // remove back button text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // set title
    NSString *title = [[self.detailsFriendData objectForKey:@"gender"]isEqualToString:@"Female"] ? @"Ms." : @"Mr.";
    NSString *lastName = [self.detailsFriendData objectForKey:@"last_name"];
    NSString *titleAndName = [[NSArray arrayWithObjects:title, lastName, nil] componentsJoinedByString:@" "];
    self.title = titleAndName;
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.userInteractionEnabled = YES;
    webView.delegate = self;
    webView.dataDetectorTypes = (UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink);
    
    [self.view addSubview:webView];
    
    [webView loadHTMLString:[self htmlStringFromFriendData] baseURL:[[NSBundle mainBundle] resourceURL]];
}

- (NSString *)htmlStringFromFriendData {
    
    // create text elements, fonts and image
    NSMutableArray *texts = [NSMutableArray new];
    NSString *textFormat = @"<div><p class='thick'>%@</p><p>%@</p></div>";
    
    [texts addObject:[NSString stringWithFormat:textFormat, @"First name:", [self.detailsFriendData objectForKey:@"first_name"]]];

    [texts addObject:[NSString stringWithFormat:textFormat, @"Last name:", [self.detailsFriendData objectForKey:@"last_name"]]];
    
    [texts addObject:[NSString stringWithFormat:textFormat, @"Gender:", [self.detailsFriendData objectForKey:@"gender"]]];
    
    [texts addObject:[NSString stringWithFormat:textFormat, @"Email:", [self.detailsFriendData objectForKey:@"email"]]];
    
    [texts addObject:[NSString stringWithFormat:textFormat, @"ID:", [self.detailsFriendData objectForKey:@"id"]]];

    [texts addObject:[NSString stringWithFormat:textFormat, @"IP-address:", [self.detailsFriendData objectForKey:@"ip_address"]]];
    
    NSString *textString = [texts componentsJoinedByString:@"\n"];

    NSString *imageName = [self.detailsFriendData objectForKey:@"image"];
    
    UIFont *regularFont = [UIFont systemFontOfSize:18.0];
    UIFont *thickFont = [UIFont boldSystemFontOfSize:18.0];
    
    // display: flex; flex-direction: row;
    // create format
    NSString *htmlFormat = @"<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><style type='text/css'> p { color:#262626; font-family:'%@'; font-size:%fpx; margin: 10px 10px 10px 10px; } p.thick {font-family:'%@';} div { display: flex; flex-direction: row; }</style></head><img src='%@' style='margin:auto; width:100px; display:block; padding:20px'/><body>%@</body></html>";
    
    // put elements together with the format
    NSString *htmlString = [NSString stringWithFormat:htmlFormat, regularFont.fontName, regularFont.pointSize, thickFont.fontName, imageName, textString];
    
    return htmlString;
}


@end
