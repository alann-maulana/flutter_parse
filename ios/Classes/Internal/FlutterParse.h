//
//  IParse.h
//  Bolts
//
//  Created by Alann Maulana on 20/12/18.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kParseInitialize = @"initialize";

@interface FlutterParse : NSObject

+ (void)initialize:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
