//
//  FlutterParseUtils.h
//  flutter_parse
//
//  Created by Alann Maulana on 28/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlutterParseUtils : NSObject

+ (NSDictionary*) parsingParams:(id)arguments;
+ (NSString*) stringFrom:(id) dict;

@end

NS_ASSUME_NONNULL_END
