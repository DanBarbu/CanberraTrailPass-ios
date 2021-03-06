//
//  OAWikiWebViewController.m
//  OsmAnd
//
//  Created by Alexey Kulish on 04/06/15.
//  Copyright (c) 2015 OsmAnd. All rights reserved.
//

#import "OAWikiWebViewController.h"
#import "Localization.h"
#import "OAAppSettings.h"
#import "OAUtilities.h"

@interface OAWikiWebViewController () <UIActionSheetDelegate>

@end

@implementation OAWikiWebViewController
{
    NSArray *_namesSorted;
    NSString *_contentLocale;
    NSURL *_baseUrl;
    
    CALayer *_horizontalLine;
    
    NSLocale *_currentLocal;
    id _localIdentifier;
    NSLocale *_theLocal;

}

- (id)initWithLocalizedContent:(NSDictionary *)localizedContent localizedNames:(NSDictionary *)localizedNames
{
    self = [super init];
    if (self)
    {
        _localizedNames = localizedNames;
        _localizedContent = localizedContent;
    }
    return self;
}

-(void)applyLocalization
{
    [_buttonBack setTitle:OALocalizedString(@"shared_string_back") forState:UIControlStateNormal];
    [_bottomButton setTitle:OALocalizedString(@"open_url") forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentLocal = [NSLocale autoupdatingCurrentLocale];
    _localIdentifier = [_currentLocal objectForKey:NSLocaleIdentifier];
    _theLocal = [NSLocale localeWithLocaleIdentifier:_localIdentifier];

    _horizontalLine = [CALayer layer];
    _horizontalLine.backgroundColor = [UIColorFromRGB(kBottomToolbarTopLineColor) CGColor];
    self.bottomView.backgroundColor = UIColorFromRGB(kBottomToolbarBackgroundColor);
    [self.bottomView.layer addSublayer:_horizontalLine];
    
    _contentLocale = [[OAAppSettings sharedManager] settingPrefMapLanguage];
    if (!_contentLocale)
        _contentLocale = [[NSLocale preferredLanguages] firstObject];
    
    NSString *content = [self.localizedContent objectForKey:_contentLocale];
    if (!content)
    {
        _contentLocale = @"";
        content = [self.localizedContent objectForKey:_contentLocale];
    }
    if (!content && self.localizedContent.count > 0)
    {
        _contentLocale = self.localizedContent.allKeys[0];
        content = [self.localizedContent objectForKey:_contentLocale];
    }

    _titleView.text = ([self.localizedNames objectForKey:_contentLocale] ? [self.localizedNames objectForKey:_contentLocale] : @"Wikipedia");
    
    NSString *locBtnStr = (_contentLocale.length == 0 ? @"EN" : [_contentLocale uppercaseString]);
    [_localeButton setTitle:locBtnStr forState:UIControlStateNormal];
    
    [self buildBaseUrl];
    
    if (content)
        [_contentView loadHTMLString:content baseURL:_baseUrl];
}

- (void) buildBaseUrl
{
    _baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.wikipedia.org/wiki/%@", (_contentLocale.length == 0 ? @"en" : _contentLocale), [_titleView.text isEqualToString:@"Wikipedia"] ? @"" : [[_titleView.text stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]]];
    
    //NSLog(@"baseUrl=%@", _baseUrl);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _horizontalLine.frame = CGRectMake(0.0, 0.0, DeviceScreenWidth, 0.5);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bottomButtonClicked:(id)sender
{
    if (_baseUrl)
        [[UIApplication sharedApplication] openURL:_baseUrl];
}

- (NSString *)getTranslatedLangname:(NSString *)lang
{
    return [_theLocal displayNameForKey:NSLocaleIdentifier value:lang];
}

- (IBAction)localeButtonClicked:(id)sender
{
    if (_localizedContent.allKeys.count <= 1)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:OALocalizedString(@"no_other_translations") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        return;
    }
    
    UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:OALocalizedString(@"select_language") delegate:self cancelButtonTitle:OALocalizedString(@"shared_string_cancel") destructiveButtonTitle:nil otherButtonTitles:nil];
    
    NSMutableArray *locales = [NSMutableArray array];
    NSString *nativeStr;
    for (NSString *loc in _localizedContent.allKeys)
    {
        if (loc.length == 0)
            nativeStr = loc;
        else
            [locales addObject:loc];
    }
    
    [locales sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    if (nativeStr)
        [actions addButtonWithTitle:[[self getTranslatedLangname:@"en"] capitalizedStringWithLocale:[NSLocale currentLocale]]];

    for (NSString *loc in locales)
        [actions addButtonWithTitle:[[self getTranslatedLangname:loc] capitalizedStringWithLocale:[NSLocale currentLocale]]];
    
    if (nativeStr)
        [locales insertObject:@"" atIndex:0];
    
    _namesSorted = [NSArray arrayWithArray:locales];
    
    [actions showFromRect:_localeButton.frame inView:_navBar animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        _contentLocale = _namesSorted[buttonIndex - 1];
        
        NSString *content = [self.localizedContent objectForKey:_contentLocale];

        NSString *locBtnStr = (_contentLocale.length == 0 ? @"EN" : [_contentLocale uppercaseString]);
        [_localeButton setTitle:locBtnStr forState:UIControlStateNormal];
        
        _titleView.text = ([self.localizedNames objectForKey:_contentLocale] ? [self.localizedNames objectForKey:_contentLocale] : @"Wikipedia");

        [self buildBaseUrl];
        [_contentView loadHTMLString:content baseURL:_baseUrl];
    }
}

@end
