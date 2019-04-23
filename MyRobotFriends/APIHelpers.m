//
//  APIHelpers.m
//  MyRobotFriends
//
//  Created by Kristoffer Anger on 2018-03-24.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import "APIHelpers.h"

#define BASE_URL @"https://my.api.mockaroo.com"
#define API_KEY @"59b0cda0"

@implementation APIHelpers

+ (NSURLSessionDataTask *)makeRequestWithResource:(NSString *)resource parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response))completion {
    
    // create request with url - base, path and query
    NSString *query = [self queryFromParameters:parameters];
    NSString *urlString = [[NSArray arrayWithObjects:BASE_URL, resource, query, nil]componentsJoinedByString:@""];
    
    NSLog(@"URL: %@", urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    // make request and parse the data
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data , NSURLResponse *urlResponse, NSError *error) {
        
        NSDictionary *response = nil;
        if (data) {
            NSArray *parsedData = [self parseJsonData:data];
            response = [NSDictionary dictionaryWithObjectsAndKeys:parsedData, @"result", nil];
        }
        else {
            response = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
        }
        // returning data on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(response);
        });
    }];
    [dataTask resume];
    
    return dataTask;
}

#pragma mark - helper methods

+ (NSArray *)parseJsonData:(NSData *)data {
    
    NSError *error = nil;
    NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return list;
}

+ (NSArray *)parsedCsvData:(NSData *)data {
    
    NSMutableArray *parsedData = [NSMutableArray new];
    
    NSString* csvString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    // get array of rows
    NSMutableArray *csvArray = [[csvString componentsSeparatedByString:@"\n"]mutableCopy];

    // check i file is comma or semicolon separated
    NSString *separator = [[csvString componentsSeparatedByString:@","]count] > [[csvString componentsSeparatedByString:@";"]count] ? @"," : @";";
    
    // get all keys in the csv file header
    NSArray *keys = [csvArray.firstObject componentsSeparatedByString:separator];
    
    // remove header
    [csvArray removeObjectAtIndex:0];
    
    // store row values in dictionaries
    for (NSString *row in csvArray) {
        
        NSArray *values = [row componentsSeparatedByString:separator];
        
        if (values.count == keys.count) {
            
            NSMutableDictionary *rowDict = [NSMutableDictionary new];
            for (NSInteger i = 0 ; i < keys.count ; i ++) {
                
                id value = [values objectAtIndex:i];
                NSString *key = [keys objectAtIndex:i];
                
                if (value) {
                    [rowDict setObject:value forKey:key];
                }
            }
            [parsedData addObject:rowDict];
        }
    }
    return parsedData;
}

+ (NSString*)queryFromParameters:(NSDictionary *)paramters {
    
    // create array with api key
    NSMutableArray *pairs = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"key=%@", API_KEY]];
    
    // add keys and values
    for (NSString *key in [paramters keyEnumerator]) {
        
        id value = [paramters objectForKey:key];
        if (value) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
    }
    // create query string
    NSString *returnString = [@"?" stringByAppendingString:[pairs componentsJoinedByString:@"&"]];
    return returnString;
}

@end
