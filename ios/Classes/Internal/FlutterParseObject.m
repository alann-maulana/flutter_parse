//
//  FlutterParseObject.m
//  flutter_parse
//
//  Created by Alann Maulana on 28/12/18.
//

#import "FlutterParseObject.h"
#import "PFObjectPrivate.h"
#import <Parse/Parse.h>
#import "FlutterParseUtils.h"
#import "BFTask+Private.h"

@implementation FlutterParseObject

- (instancetype) initWithParseObject:(PFObject*) parseObject {
    if (self = [super init]) {
        self.parseObject = parseObject;
    }
    
    return self;
}

+ (instancetype) createObjectWithDictionary:(NSDictionary *) dict {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
    FlutterParseObject *flutterObject = nil;
    NSString *className = dictionary[@"className"];
    if (className) {
        [dictionary removeObjectForKey:@"className"];
        PFObject *parseObject = [[PFObject alloc] initWithClassName:className];
        
        flutterObject = [[FlutterParseObject alloc] initWithParseObject:parseObject];
        NSError *error;
        [flutterObject.parseObject mergeFromRESTDictionary:dict withDecoder:[PFDecoder objectDecoder] error:&error];
    }
    
    return flutterObject;
}

+ (instancetype) createObjectWithoutDataWithDictionary:(NSDictionary *) dict {
    FlutterParseObject *flutterObject = nil;
    NSString *className = dict[@"className"];
    if (className) {
        NSString *objectId = dict[@"objectId"];
        if (objectId) {
            PFObject *parseObject = [PFObject objectWithoutDataWithClassName:className objectId:objectId];
            flutterObject = [[FlutterParseObject alloc] initWithParseObject:parseObject];
        }
    }
    
    return flutterObject;
}

+ (void)saveAsync:(FlutterMethodCall*)call result:(FlutterResult)result eventually:(BOOL)eventually {
    NSDictionary* dict = [FlutterParseUtils parsingParams:call.arguments];
    
    if (!dict) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"invalid parse object" details:nil]);
        return;
    }
    
    FlutterParseObject *object = [FlutterParseObject createObjectWithDictionary:dict];
    if (!object) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"no className found" details:nil]);
        return;
    }
    
    PFBooleanResultBlock block = ^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
            return;
        }
        
        NSArray *operationSetUUIDs = nil;
        error = nil;
        NSDictionary *resultDict = [object.parseObject RESTDictionaryWithObjectEncoder:[PFEncoder objectEncoder] operationSetUUIDs:&operationSetUUIDs error:&error];
        result([FlutterParseUtils stringFrom:resultDict]);
    };
    
    if (eventually) {
        [object.parseObject saveEventually:block];
    } else {
        [object.parseObject saveInBackgroundWithBlock:block];
    }
}

+ (void)deleteAsync:(FlutterMethodCall*)call result:(FlutterResult)result eventually:(BOOL)eventually {
    NSDictionary* dict = [FlutterParseUtils parsingParams:call.arguments];
    
    if (!dict) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"invalid parse object" details:nil]);
        return;
    }
    
    FlutterParseObject *object = [FlutterParseObject createObjectWithoutDataWithDictionary:dict];
    if (!object) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"no className found" details:nil]);
        return;
    }
    
    PFBooleanResultBlock block = ^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
            return;
        }
        
        result(@(YES));
    };
    if (eventually) {
        [[object.parseObject deleteEventually] thenCallBackOnMainThreadWithBoolValueAsync:block];
    } else {
        [object.parseObject deleteInBackgroundWithBlock:block];
    }
}

+ (void)fetchAsync:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* dict = [FlutterParseUtils parsingParams:call.arguments];
    
    if (!dict) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"invalid parse object" details:nil]);
        return;
    }
    
    FlutterParseObject *parseObject = [FlutterParseObject createObjectWithoutDataWithDictionary:dict];
    if (!parseObject) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"no className found" details:nil]);
        return;
    }
    
    [parseObject.parseObject fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
            return;
        }
        
        result([FlutterParseUtils stringFrom:[parseObject dictionary]]);
    }];
}

- (NSDictionary*) dictionary {
    NSArray *operationSetUUIDs = nil;
    NSError *error = nil;
    NSDictionary *resultDict = [self.parseObject RESTDictionaryWithObjectEncoder:[PFEncoder objectEncoder] operationSetUUIDs:&operationSetUUIDs error:&error];
    if (error) return nil;
    
    return resultDict;
}

@end
