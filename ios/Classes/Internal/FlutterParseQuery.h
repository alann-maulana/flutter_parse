//
//  FlutterParseQuery.h
//  flutter_parse
//
//  Created by Alann Maulana on 29/12/18.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

static const NSString* kParseQueryInBackground = @"queryInBackground";

@interface FlutterParseQuery : NSObject

+ (void)executeAsync:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
