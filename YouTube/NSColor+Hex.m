//
//  NSColor+Hex.m
//  YouTube
//
//  Created by Chloe Stars on 11/7/12.
//  Copyright (c) 2012 Phantom Sun Creative. All rights reserved.
//

#import "NSColor+Hex.h"

@implementation NSColor (Hex)

// taken from http://stackoverflow.com/questions/8697205/convert-hex-color-code-to-nscolor
+ (NSColor*)colorWithHexColorString:(NSString*)inColorString
{
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
	
    if (nil != inColorString)
    {
		NSScanner* scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
	
    result = [NSColor
			  colorWithCalibratedRed:(CGFloat)redByte / 0xff
			  green:(CGFloat)greenByte / 0xff
			  blue:(CGFloat)blueByte / 0xff
			  alpha:1.0];
    return result;
}

@end
