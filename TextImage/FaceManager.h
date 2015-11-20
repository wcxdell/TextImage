//
//  FaceManager.h
//  TextImage
//
//  Created by 王长旭 on 15/11/5.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define faceName @"face_name"

@interface FaceManager : NSObject
@property (strong,nonatomic) NSMutableArray * emojiFaceArrays;


+ (NSMutableAttributedString*) replaceStrWithEmotion:(NSString*) message;
+ (instancetype)shareInstance;

+ (NSString*)faceImageNameWithFaceID:(NSString *) faceId;

@end
