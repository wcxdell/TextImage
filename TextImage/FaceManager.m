//
//  FaceManager.m
//  TextImage
//
//  Created by 王长旭 on 15/11/5.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import "FaceManager.h"

@interface FaceManager ()


@end

@implementation FaceManager

- (instancetype)init{
    if (self = [super init]) {
        _emojiFaceArrays = [NSMutableArray array];
        
        NSArray *faceArray = [NSArray arrayWithContentsOfFile:[FaceManager defaultEmojiFacePath]];
        [_emojiFaceArrays addObjectsFromArray:faceArray];
    }
    return self;
}

+ (NSString *)defaultEmojiFacePath{
    return [[NSBundle mainBundle] pathForResource:@"faceList" ofType:@"plist"];
}

#pragma mark - Class Methods

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static id shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

+ (NSMutableAttributedString*) replaceStrWithEmotion:(NSString*) message{

    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:message];
    NSString *regex_emoji = @"\\[--[0-9]+\\]";
    
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    for(NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        NSString *subStr = [message substringWithRange:range];
        
        for (NSDictionary *dict in [[FaceManager shareInstance] emojiFaceArrays]) {
            if ([dict[faceName]  isEqualToString:subStr]) {
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.image = [UIImage imageNamed:dict[faceName]];
                textAttachment.bounds = CGRectMake(0, -8, textAttachment.image.size.width, textAttachment.image.size.height);
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                [imageArray addObject:imageDic];
                break;
            }
        }
    }
    
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    return attributeString;
}

+ (NSString*)faceImageNameWithFaceID:(NSString *) faceId{
    if ([faceId isEqualToString:@"100"]) {
        return @"[--100]";
    }
    for (NSDictionary *faceDict in [[FaceManager shareInstance] emojiFaceArrays]) {
        if ([faceDict[@"face_id"] isEqualToString:faceId]) {
            return faceDict[@"face_name"];
        }
    }
    return @"";
}

@end
