//
//  OAUtilities.m
//  OsmAnd
//
//  Created by Alexey Pelykh on 9/24/14.
//  Copyright (c) 2014 OsmAnd. All rights reserved.
//

#import "OAUtilities.h"

#import <UIKit/UIDevice.h>

@implementation OAUtilities

+ (BOOL)iosVersionIsAtLeast:(NSString*)testVersion
{
    return ([[[UIDevice currentDevice] systemVersion] compare:testVersion options:NSNumericSearch] != NSOrderedAscending);
}

+ (BOOL)iosVersionIsExactly:(NSString*)testVersion
{
    return ([[[UIDevice currentDevice] systemVersion] compare:testVersion options:NSNumericSearch] == NSOrderedSame);
}

+ (UIImage *)applyScaleFactorToImage:(UIImage *)image
{
    @autoreleasepool
    {
        CGFloat scaleFactor = [[UIScreen mainScreen] scale];
        CGSize newSize = CGSizeMake(image.size.width / scaleFactor, image.size.height / scaleFactor);
        
        UIGraphicsBeginImageContextWithOptions(newSize, NO, scaleFactor);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

+ (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

+ (NSString *)drawablePostfix
{
    int scale = (int)[UIScreen mainScreen].scale;
    
    switch (scale) {
        case 1:
            return @"mdpi";
        case 2:
            return @"xhdpi";
        case 3:
            return @"xxhdpi";
            
        default:
            return @"xxhdpi";
    }
}

+ (void)layoutComplexButton:(UIButton*)button
{
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}


+ (CGSize)calculateTextBounds:(NSString *)text width:(CGFloat)width font:(UIFont *)font
{
    NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              font, NSFontAttributeName, nil];
    
    CGSize size = [text boundingRectWithSize:CGSizeMake(width, 10000.0)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attrDict context:nil].size;
    
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

+ (CGSize)calculateTextBounds:(NSString *)text width:(CGFloat)width height:(CGFloat)height font:(UIFont *)font
{
    NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              font, NSFontAttributeName, nil];
    
    CGSize size = [text boundingRectWithSize:CGSizeMake(width, height)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                  attributes:attrDict context:nil].size;
    
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

+ (NSDictionary *)parseUrlQuery:(NSURL *)url
{
    NSMutableDictionary *queryStrings = [[NSMutableDictionary alloc] init];
    for (NSString *qs in [url.query componentsSeparatedByString:@"&"]) {
        // Get the parameter name
        NSString *key = [[qs componentsSeparatedByString:@"="] objectAtIndex:0];
        // Get the parameter value
        NSString *value = [[qs componentsSeparatedByString:@"="] objectAtIndex:1];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        queryStrings[key] = value;
    }
    return [NSDictionary dictionaryWithDictionary:queryStrings];
}

+ (void)getHMS:(NSTimeInterval)timeInterval hours:(int*)hours minutes:(int*)minutes seconds:(int*)seconds
{
    long secondsL = lroundf(timeInterval);
    *hours = abs(secondsL / 3600);
    *minutes = abs((secondsL % 3600) / 60);
    *seconds = abs(secondsL % 60);
}

+ (NSArray *) splitCoordinates:(NSString *)string
{
        NSMutableArray *split = [NSMutableArray array];
        NSMutableString *prev = [NSMutableString string];
        NSMutableString *other = [NSMutableString string];
        BOOL south = NO;
        BOOL west = NO;
        for(int i = 0; i < string.length; i++)
        {
            unichar ch = [string characterAtIndex:i];
            
            if(ch == '\'' || [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch] || ch =='#' ||
               ch == '-' || ch == '.')
            {
                [prev appendString:[NSString stringWithCharacters:&ch length:1]];
                if ([[[other stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] lowercaseString] isEqualToString:@"s"])
                    south = true;
                
                [other setString:@""];
            }
            else
            {
                [other appendString:[NSString stringWithCharacters:&ch length:1]];
                if (prev.length > 0)
                {
                    [split addObject:[NSString stringWithString:prev]];
                    [prev setString:@""];
                }
            }
        }
        if (prev.length > 0)
        {
            [split addObject:[NSString stringWithString:prev]];
            [prev setString:@""];
        }
        if ([[[other stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] lowercaseString] isEqualToString:@"w"])
            west = YES;
    
        NSMutableArray *numbers = [OAUtilities splitNumbers:split];
        NSMutableArray *dnumbers = [OAUtilities filterInts:numbers];
        NSMutableArray *rnumbers = dnumbers.count >= 2 ? dnumbers : numbers;
        if (rnumbers.count > 0 && [rnumbers[0] doubleValue] >= 0 && south)
            [rnumbers setObject:[NSNumber numberWithDouble:-[rnumbers[0] doubleValue]] atIndexedSubscript:0];
        if (rnumbers.count > 1 && [rnumbers[1] doubleValue] >= 0 && west)
            [rnumbers setObject:[NSNumber numberWithDouble:-[rnumbers[1] doubleValue]] atIndexedSubscript:1];

        if (rnumbers.count == 0) // Not a coordinate
            return nil;
        else if(rnumbers.count == 1) // Latitude X Longitude #.## or ##’##’##.#
            return @[rnumbers[0]];
        else // Latitude X Longitude Y
            return @[rnumbers[0], rnumbers[1]];
}

+ (NSMutableArray *) filterInts:(NSArray *)numbers
{
    NSMutableArray *dnumbers = [NSMutableArray array];
    for (NSNumber *d in numbers)
        if([d intValue] != [d doubleValue])
            [dnumbers addObject:d];
    
    return dnumbers;
}

+ (NSMutableArray *) splitNumbers:(NSArray *) split
{
        NSMutableString *prev = [NSMutableString string];
        NSMutableArray *numbers = [NSMutableArray array];
        for (NSString *p in split)
        {
            NSMutableArray *ps = [NSMutableArray array];
            [prev setString:@""];
            for (int i = 0; i < p.length; i++)
            {
                unichar ch = [p characterAtIndex:i];
                if (ch =='#' || ch == '\'')
                {
                    if(!(prev.length > 0 && [prev characterAtIndex:0] == '-'))
                        [prev replaceOccurrencesOfString:@"-" withString:@"" options:0 range:NSMakeRange(0, prev.length)];
                    
                    [OAUtilities addPrev:prev ps:ps];
                    [prev setString:@""];
                }
                else
                {
                    [prev appendString:[NSString stringWithCharacters:&ch length:1]];
                }
            }
            [OAUtilities addPrev:prev ps:ps];
            if (ps.count > 0)
            {
                double n = [ps[0] doubleValue];
                if (ps.count > 1)
                {
                    n += [ps[1] doubleValue] / 60.0;
                    if (ps.count > 2)
                        n += [ps[2] doubleValue] / 3600.0;
                }
                [numbers addObject:[NSNumber numberWithDouble:n]];
            }
        }
        return numbers;
}
    
+ (void) addPrev:(NSString *)prev ps:(NSMutableArray *)ps
{
    NSString *trimmed = [prev stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    if (trimmed.length > 0)
    {
        double val = [trimmed doubleValue];
        if (val != HUGE_VAL && val != -HUGE_VAL && val != 0.0)
            [ps addObject:[NSNumber numberWithDouble:val]];
    }
}

+ (NSString *) floatToStrTrimZeros:(CGFloat)number
{
    NSString *str = [NSString stringWithFormat:@"%f", number];
    int length = str.length;
    for (int i = str.length; i > 0; i--)
    {
        if  ([str rangeOfString:@"."].location != NSNotFound)
        {
            NSRange prevChar = NSMakeRange(i-1, 1);
            if ([[str substringWithRange:prevChar] isEqualToString:@"0"]||
                [[str substringWithRange:prevChar] isEqualToString:@"."])
                length--;
            else
                break;
        }
        str = [str substringToIndex:length];
    }
    return str;
}

+ (UIImage *)tintImageWithColor:(UIImage *)source color:(UIColor *)color
{
    @autoreleasepool
    {
        // begin a new image context, to draw our colored image onto with the right scale
        UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
        
        // get a reference to that context we created
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // set the fill color
        [color setFill];
        
        // translate/flip the graphics context (for transforming from CG* coords to UI* coords
        CGContextTranslateCTM(context, 0, source.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
        CGContextDrawImage(context, rect, source.CGImage);
        
        CGContextClipToMask(context, rect, source.CGImage);
        CGContextAddRect(context, rect);
        CGContextDrawPath(context,kCGPathFill);
        
        // generate a new UIImage from the graphics context we drew onto
        UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return the color-burned image
        return coloredImg;
    }
}

+ (NSString *)colorToString:(UIColor *)color
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    uint32_t red = r * 255;
    uint32_t green = g * 255;
    uint32_t blue = b * 255;
    
    return [NSString stringWithFormat:@"#%.6x", (red << 16) + (green << 8) + blue];
}

+ (UIColor *)colorFromString:(NSString *)string
{
    string = [string lowercaseString];
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    
    switch ([string length])
    {
        case 0:
        {
            string = @"00000000";
            break;
        }
        case 3:
        {
            NSString *red = [string substringWithRange:NSMakeRange(0, 1)];
            NSString *green = [string substringWithRange:NSMakeRange(1, 1)];
            NSString *blue = [string substringWithRange:NSMakeRange(2, 1)];
            string = [NSString stringWithFormat:@"%1$@%1$@%2$@%2$@%3$@%3$@ff", red, green, blue];
            break;
        }
        case 6:
        {
            string = [string stringByAppendingString:@"ff"];
            break;
        }
        case 8:
        {
            //do nothing
            break;
        }
        default:
        {
            return nil;
        }
    }

    uint32_t rgba;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanHexInt:&rgba];
    return UIColorFromRGBA(rgba);
}

+ (BOOL)areColorsEqual:(UIColor *)color1 color2:(UIColor *)color2
{
    NSString *col1Str = [self.class colorToString:color1];
    NSString *col2Str = [self.class colorToString:color2];
    return [col1Str isEqualToString:col2Str];
}

+ (BOOL)doublesEqualUpToDigits:(int)digits source:(double)source destination:(double)destination
{
    double ap = source * pow(10.0, digits);
    double bp = destination * pow(10.0, digits);
    
    long a = (long)round(ap);
    long b = (long)round(bp);
    long af = (long)floor(ap);
    long bf = (long)floor(bp);
    
    return a == b || af == bf;
}

+ (void)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(CGFloat)radius
{    
    if (tl || tr || bl || br)
    {
        UIRectCorner corner = 0;

        if (tl)
            corner = corner | UIRectCornerTopLeft;

        if (tr)
            corner = corner | UIRectCornerTopRight;

        if (bl)
            corner = corner | UIRectCornerBottomLeft;

        if (br)
            corner = corner | UIRectCornerBottomRight;

        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = view.bounds;
        maskLayer.path = maskPath.CGPath;
        view.layer.mask = maskLayer;
    }
}

@end
