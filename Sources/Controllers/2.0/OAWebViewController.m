//
//  OAWebViewController.m
//  OsmAnd
//
//  Created by Anton Rogachevskiy on 27.11.14.
//  Copyright (c) 2014 OsmAnd. All rights reserved.
//

#import "OAWebViewController.h"
#import "Localization.h"

@interface OAWebViewController ()

@end

@implementation OAWebViewController

-(id)initWithUrl:(NSString*)url {
    self = [super init];
    if (self) {
        self.urlString = url;
    }
    return self;
}

-(void)applyLocalization
{
    _titleLabel.text = OALocalizedString(@"help_quiz");
    [_backButton setTitle:OALocalizedString(@"shared_string_back") forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *websiteUrl = [NSURL URLWithString:self.urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [_webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
