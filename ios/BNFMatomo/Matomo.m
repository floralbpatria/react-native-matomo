//
//  Matomo.m
//

#import "Matomo.h"
#import "BNFMatomo-Swift.h"

#if DEBUG
#if __has_include(<React/RCTLog.h>)
#import <React/RCTLog.h>
#elif __has_include("RCTLog.h")
#import "RCTLog.h"
#elif __has_include("React/RCTLog.h")
#import "React/RCTLog.h"   // Required when used as a Pod in a Swift project
#endif
#endif

@implementation Matomo
{
    MatomoTracker* tracker;
}

static NSString * const MatamoAppTrackingKey = @"@@Matamo-tracking-version@@";

+ (NSString *)appTrackId {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@-%@-(%@)", appDisplayName, majorVersion, minorVersion];
}

+ (float)appVersion {
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initTracker: (NSString*)url id:(NSNumber* _Nonnull) id userAgent:(NSString*)userAgent)
{
#if DEBUG
    RCTLogInfo(@"Initing tracker");
#endif
    tracker = [[MatomoTracker alloc] initWithSiteId:[id stringValue] baseURL:[NSURL URLWithString: url] userAgent: userAgent];
}

RCT_EXPORT_METHOD(setUserId:(NSString* _Nonnull)userID)
{
#if DEBUG
    RCTLogInfo(@"Setting user id");
#endif
    if (tracker != nil) {
        tracker.userId = userID;
    }
}

RCT_EXPORT_METHOD(setIsOptedOut:(BOOL)isOptedOut)
{
#if DEBUG
    RCTLogInfo(@"Setting IsOptedOut");
#endif
    if (tracker != nil) {
        tracker.isOptedOut = isOptedOut;
    }
}

RCT_EXPORT_METHOD(trackScreen: (NSString* _Nonnull)path title: (NSString* _Nullable)title)
{
#if DEBUG
    RCTLogInfo(@"Tracking screen");
#endif
    if (tracker != nil) {
        NSArray* views = [title componentsSeparatedByString:@"/"];
        NSURL* nsUrl = path != nil ? [NSURL URLWithString: path] : nil;
        [tracker trackWithView:views url:nsUrl];
    }
}

RCT_EXPORT_METHOD(trackGoal: (NSUInteger)goal values:(NSDictionary* _Nonnull) values)
{
#if DEBUG
    RCTLogInfo(@"Tracking goal");
#endif
    if (tracker != nil) {
        NSNumber* revenue = [values objectForKey:@"revenue"];
        [tracker trackGoalWithId:@(goal) revenue: revenue];
    }
}

RCT_EXPORT_METHOD(trackEvent: (NSString* _Nonnull)category action:(NSString* _Nonnull) action values:(NSDictionary* _Nonnull) values)
{
#if DEBUG
    RCTLogInfo(@"Tracking event");
#endif
    if (tracker != nil) {
        NSString * name = [values objectForKey:@"name"];
        NSNumber* value = [values objectForKey:@"value"];
        NSString * url = [values objectForKey:@"url"];
        NSURL* nsUrl = url != nil ? [NSURL URLWithString: url] : nil;
        [tracker trackWithEventWithCategory:category action:action name:name number:value url:nsUrl];
    }
}

RCT_EXPORT_METHOD(trackCampaign:(NSString* _Nullable)name keyboard:(NSString* _Nullable)keyboard)
{
#if DEBUG
    RCTLogInfo(@"Tracking campaign");
#endif
    if (tracker != nil) {
        [tracker trackCampaignWithName:name keyword:keyboard];
    }
}

RCT_EXPORT_METHOD(trackContentImpression:(NSString* _Nonnull)name values:(NSDictionary* _Nonnull)values)
{
#if DEBUG
    RCTLogInfo(@"Tracking content impression");
#endif
    if (tracker != nil) {
        NSString * piece = [values objectForKey:@"piece"];
        NSString* target = [values objectForKey:@"target"];
        [tracker trackContentImpressionWithName:name piece:piece target:target];
    }
}

RCT_EXPORT_METHOD(trackContentInteraction:(NSString* _Nonnull)name values:(NSDictionary* _Nonnull)values)
{
#if DEBUG
    RCTLogInfo(@"Tracking content interaction");
#endif
    if (tracker != nil) {
        NSString * interaction = [values objectForKey:@"interaction"];
        NSString * piece = [values objectForKey:@"piece"];
        NSString* target = [values objectForKey:@"target"];
        [tracker trackContentInteractionWithName:name interaction:interaction piece:piece target:target];
    }
}

RCT_EXPORT_METHOD(trackSearch:(NSString* _Nonnull)query values:(NSDictionary* _Nonnull) values)
{
#if DEBUG
    RCTLogInfo(@"Tracking search");
#endif
    if (tracker != nil) {
        NSString * category = [values objectForKey:@"category"];
        NSString * resultCount = [values objectForKey:@"resultCount"];
        NSString * url = [values objectForKey:@"url"];

        NSInteger intResultCount = resultCount != nil ? [resultCount integerValue] : 0;
        NSURL* nsUrl = url != nil ? [NSURL URLWithString: url] : nil;

        [tracker trackSearchWithQuery:query category:category resultCount:intResultCount url:nsUrl];
    }
}

RCT_EXPORT_METHOD(trackAppDownload)
{
#if DEBUG
    RCTLogInfo(@"Unsupported on iOS");
#endif
}

@end
