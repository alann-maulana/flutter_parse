//
//  FlutterParseEncoder.m
//  flutter_parse
//
//  Created by Alann Maulana on 31/12/18.
//

#import "FlutterParseEncoder.h"
#import "FlutterParseObject.h"
#import <Parse/Parse.h>
#import "PFObjectPrivate.h"
#import "PFObjectState.h"

@implementation FlutterParseEncoder

+ (instancetype)objectEncoder {
    static FlutterParseEncoder *encoder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encoder = [[FlutterParseEncoder alloc] init];
    });
    return encoder;
}

- (id)encodeParseObject:(PFObject *)object error:(NSError **)error {
    if (object._state.isComplete) {
        FlutterParseObject *parseObject = [[FlutterParseObject alloc] initWithParseObject:object];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"__type"] = @"Object";
        [dict addEntriesFromDictionary:[parseObject dictionary]];
        
        return [NSDictionary dictionaryWithDictionary:dict];
    }
    return @{
             @"__type" : @"Pointer",
             @"objectId" : object.objectId,
             @"className" : object.parseClassName
             };
}

@end
