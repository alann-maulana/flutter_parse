//
//  FlutterParseUtils.m
//  flutter_parse
//
//  Created by Alann Maulana on 28/12/18.
//

#import "FlutterParseUtils.h"
#import "PFJSONSerialization.h"

@implementation FlutterParseUtils

+ (NSDictionary*) parsingParams:(id)argument {
    NSDictionary *dict = nil;
    if ([argument isKindOfClass:[NSString class]]) {
        NSString *string = argument;
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        dict = [PFJSONSerialization JSONObjectFromData:data];
    } else if ([argument isKindOfClass:[NSDictionary class]]) {
        dict = argument;
    }
    
    return dict;
}

+ (NSString*) stringFrom:(id) dict {
    return [PFJSONSerialization stringFromJSONObject:dict];
}

@end
