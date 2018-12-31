//
//  FlutterParseQuery.m
//  flutter_parse
//
//  Created by Alann Maulana on 29/12/18.
//

#import "FlutterParseQuery.h"
#import <Parse/Parse.h>
#import "FlutterParseUtils.h"
#import "FlutterParseObject.h"
#import "PFQueryPrivate.h"
#import "PFRESTQueryCommand.h"

@interface FlutterParseQuery()

@property (strong, nonatomic) PFQuery *query;
@property (assign) BOOL count;

@end

@implementation FlutterParseQuery

- (instancetype)initWithQuery:(PFQuery*) query withCountQuery:(BOOL) count {
    if (self = [super init]) {
        _query = query;
        _count = count;
    }
    
    return self;
}

+ (instancetype)createQuery:(NSDictionary*) dict {
    NSString *className = dict[@"className"];
    if (!className) {
        return nil;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:className];
    PFDecoder *decoder = [PFDecoder objectDecoder];
    
    NSDictionary *where = dict[@"where"];
    [where enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *clause = obj;
            NSString *type = clause[@"__type"];
            if (type) {
                [query whereKey:key equalTo:[decoder decodeObject:obj]];
            } else {
                [clause enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull keyClause, id  _Nonnull objClause, BOOL * _Nonnull stop) {
                    [self parseQuery:query withKey:key keyClause:keyClause andValue:[decoder decodeObject:objClause]];
                }];
            }
        } else {
            [query whereKey:key equalTo:obj];
        }
    }];
    
    BOOL count = NO;
    NSNumber *numberCount = dict[@"count"];
    if (numberCount) {
        count = numberCount.intValue == 1;
    }
    
    NSNumber *limit = dict[@"limit"];
    if (!limit && limit != 0) {
        query.limit = limit.integerValue;
    }
    
    NSNumber *skip = dict[@"skip"];
    if (!skip) {
        query.skip = skip.integerValue;
    }
    
    NSString *include = dict[@"include"];
    if (include.length > 0) {
        NSArray *split = [include componentsSeparatedByString:@","];
        if (split.count > 0) {
            [query includeKeys:split];
        } else {
            [query includeKey:include];
        }
    }
    
    NSString *order = dict[@"order"];
    if (order.length > 0) {
        NSArray *split = [order componentsSeparatedByString:@","];
        for (NSString *o in split) {
            BOOL desc = [o containsString:@"-"];
            NSString *key = [o stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            if (desc) {
                [query addDescendingOrder:key];
            } else {
                [query addAscendingOrder:key];
            }
        }
    }
    
    NSString* fields = dict[@"fields"];
    if (fields.length > 0) {
        NSArray *split = [fields componentsSeparatedByString:@","];
        [query selectKeys:split];
    }
    
    return [[FlutterParseQuery alloc] initWithQuery:query withCountQuery:count];
}

+ (void)parseQuery:(PFQuery*) query withKey:(NSString*)key keyClause:(NSString*)keyClause andValue:(id)value {
    PFDecoder *decoder = [PFDecoder objectDecoder];
    
    if ([keyClause isEqualToString:@"whereLessThan"]) {
        [query whereKey:key lessThan:value];
    } else if ([keyClause isEqualToString:@"whereNotEqualTo"]) {
        [query whereKey:key notEqualTo:value];
    } else if ([keyClause isEqualToString:@"whereGreaterThan"]) {
        [query whereKey:key greaterThan:value];
    } else if ([keyClause isEqualToString:@"whereLessThanOrEqualTo"]) {
        [query whereKey:key lessThanOrEqualTo:value];
    } else if ([keyClause isEqualToString:@"whereGreaterThanOrEqualTo"]) {
        [query whereKey:key greaterThanOrEqualTo:value];
    } else if ([keyClause isEqualToString:@"whereContainedIn"] && [value isKindOfClass:[NSArray class]]) {
        [query whereKey:key containedIn:value];
    } else if ([keyClause isEqualToString:@"whereContainsAll"] && [value isKindOfClass:[NSArray class]]) {
        [query whereKey:key containsAllObjectsInArray:value];
    } else if ([keyClause isEqualToString:@"whereFullText"] && [value isKindOfClass:[NSString class]]) {
        // not implemented
    } else if ([keyClause isEqualToString:@"whereNotContainedIn"] && [value isKindOfClass:[NSArray class]]) {
        [query whereKey:key notContainedIn:value];
    } else if ([keyClause isEqualToString:@"whereMatches"] && [value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = value;
        NSString *regex = dict[@"regex"];
        NSString *modifiers = dict[@"modifiers"];
        if (modifiers.length != 0) {
            [query whereKey:key matchesRegex:regex modifiers:modifiers];
        } else {
            [query whereKey:key matchesRegex:regex];
        }
    } else if ([keyClause isEqualToString:@"whereContains"] && [value isKindOfClass:[NSString class]]) {
        [query whereKey:key containsString:value];
    } else if ([keyClause isEqualToString:@"whereStartsWith"] && [value isKindOfClass:[NSString class]]) {
        [query whereKey:key hasPrefix:value];
    } else if ([keyClause isEqualToString:@"whereEndsWith"] && [value isKindOfClass:[NSString class]]) {
        [query whereKey:key hasSuffix:value];
    } else if ([keyClause isEqualToString:@"whereExists"]) {
        [query whereKeyExists:key];
    } else if ([keyClause isEqualToString:@"whereExists"]) {
        [query whereKeyDoesNotExist:key];
    } else if ([keyClause isEqualToString:@"whereDoesNotMatchKeyInQuery"] && [value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = value;
        NSString *keyInQuery = param[@"keyInQuery"];
        NSDictionary *queryNotMatches = param[@"query"];
        FlutterParseQuery *parseQuery = [FlutterParseQuery createQuery:queryNotMatches];
        if (parseQuery) {
            [query whereKey:key doesNotMatchKey:keyInQuery inQuery:parseQuery.query];
        }
    } else if ([keyClause isEqualToString:@"whereMatchesKeyInQuery"] && [value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = value;
        NSString *keyInQuery = param[@"keyInQuery"];
        NSDictionary *queryMatches = param[@"query"];
        FlutterParseQuery *parseQuery = [FlutterParseQuery createQuery:queryMatches];
        if (parseQuery) {
            [query whereKey:key matchesKey:keyInQuery inQuery:parseQuery.query];
        }
    } else if ([keyClause isEqualToString:@"whereDoesNotMatchQuery"] && [value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = value;
        FlutterParseQuery *parseQuery = [FlutterParseQuery createQuery:param];
        if (parseQuery) {
            [query whereKey:key doesNotMatchQuery:parseQuery.query];
        }
    } else if ([keyClause isEqualToString:@"whereMatchesQuery"] && [value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = value;
        FlutterParseQuery *parseQuery = [FlutterParseQuery createQuery:param];
        if (parseQuery) {
            [query whereKey:key matchesQuery:parseQuery.query];
        }
    } else if ([keyClause isEqualToString:@"whereNear"] && [value isKindOfClass:[NSDictionary class]]) {
        PFGeoPoint *point = [decoder decodeObject:value];
        [query whereKey:key nearGeoPoint:point];
    } else if ([keyClause isEqualToString:@"whereWithinRadians"] && [value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = value;
        PFGeoPoint *point = [decoder decodeObject:param[@"point"]];
        NSNumber *maxDistance = param[@"maxDistance"];
        [query whereKey:key nearGeoPoint:point withinRadians:maxDistance.doubleValue];
    } else if ([keyClause isEqualToString:@"whereWithinGeoBox"] && [value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        PFGeoPoint *northWest = [decoder decodeObject:array[0]];
        PFGeoPoint *southEast = [decoder decodeObject:array[1]];
        [query whereKey:key withinGeoBoxFromSouthwest:northWest toNortheast:southEast];
    } else if ([keyClause isEqualToString:@"whereWithinPolygon"] && [value isKindOfClass:[NSArray class]]) {
        NSArray *array = [decoder decodeObject:value];
        [query whereKey:key withinPolygon:array];
    } else if ([keyClause isEqualToString:@"wherePolygonContains"] && [value isKindOfClass:[NSDictionary class]]) {
        PFGeoPoint *point = [decoder decodeObject:value];
        [query whereKey:key polygonContains:point];
    }
}

+ (void)executeAsync:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *dict = [FlutterParseUtils parsingParams:call.arguments];
    if (!dict) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"invalid parse object" details:nil]);
        return;
    }
    
    FlutterParseQuery *parseQuery = [FlutterParseQuery createQuery:dict];
    if (!parseQuery) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", kPFErrorInvalidJSON] message:@"invalid class name" details:nil]);
        return;
    }
    
//    NSError *e = nil;
//    NSLog(@"QUERY2=%@", [PFRESTQueryCommand findCommandParametersForQueryState:parseQuery.query.state error:&e]);
    
    if (parseQuery.count) {
        [parseQuery.query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            if (error) {
                result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
                return;
            }
            
            result(@(number));
        }];
    } else {
        [parseQuery.query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error) {
                result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code] message:error.localizedDescription details:nil]);
                return;
            }
            
            NSMutableArray *array = [NSMutableArray array];
            [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FlutterParseObject *object = [[FlutterParseObject alloc] initWithParseObject:obj];
                [array addObject:[object dictionary]];
            }];
            result([FlutterParseUtils stringFrom:array]);
        }];
    }
}

@end
