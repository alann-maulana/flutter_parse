//
//  FlutterParseObject.h
//  flutter_parse
//
//  Created by Alann Maulana on 28/12/18.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

static const NSString* kParseObjectFetchInBackground = @"fetchInBackground";
static const NSString* kParseObjectDeleteInBackground = @"deleteInBackground";
static const NSString* kParseObjectDeleteEventually = @"deleteEventually";
static const NSString* kParseObjectSaveInBackground = @"saveInBackground";
static const NSString* kParseObjectSaveEventually = @"saveEventually";

@class PFObject;
@interface FlutterParseObject : NSObject

@property (strong, nonatomic) PFObject* parseObject;

- (instancetype) initWithParseObject:(PFObject*) parseObject;
+ (void)saveAsync:(FlutterMethodCall*)call result:(FlutterResult)result eventually:(BOOL)eventually;
+ (void)deleteAsync:(FlutterMethodCall*)call result:(FlutterResult)result eventually:(BOOL)eventually;
+ (void)fetchAsync:(FlutterMethodCall*)call result:(FlutterResult)result;
- (NSDictionary*) dictionary;

@end

NS_ASSUME_NONNULL_END
