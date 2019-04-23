//
//  APIHelpers.h
//  MyRobotFriends
//
//  Created by Kristoffer Anger on 2018-03-24.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIHelpers : NSObject

+ (NSURLSessionDataTask *)makeRequestWithResource:(NSString *)resource parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response))completion;

@end
