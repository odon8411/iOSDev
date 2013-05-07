//
//  WBAuthorize.m
//  SinaWeiBoSDK
//  Based on OAuth 2.0
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright 2011 Sina. All rights reserved.
//

#import "WBAuthorize.h"
#import "WBRequest.h"
#import "WBSDKGlobal.h"





@interface WBAuthorize (Private)

- (void)dismissModalViewController;
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;
- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password;

@end

@implementation WBAuthorize
@synthesize qqOpenid;
@synthesize snsType;
@synthesize appKey;
@synthesize appSecret;
@synthesize redirectURI;
@synthesize request;
@synthesize rootViewController;
@synthesize delegate;

#pragma mark - WBAuthorize Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init])
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
    }
    
    return self;
}

- (void)dealloc
{
    [snsType release],snsType= nil;
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    
    [redirectURI release], redirectURI = nil;
    
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    
    rootViewController = nil;
    delegate = nil;
    
    [super dealloc];
}
#pragma mark - qq get info from url
- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
	NSString * str = nil;
	NSRange start = [url rangeOfString:needle];
	if (start.location != NSNotFound) {
		NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
		NSUInteger offset = start.location+start.length;
		str = end.location == NSNotFound
		? [url substringFromIndex:offset]
		: [url substringWithRange:NSMakeRange(offset, end.location)];
		str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	
	return str;
}

#pragma mark - WBAuthorize Private Methods

- (void)dismissModalViewController
{
    [rootViewController dismissModalViewControllerAnimated:YES];
}

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
	NSString *url = kWBAccessTokenURL;
	

	
	
	if([snsType isEqualToString:@"qq"]) {
		
		url = kQQAccessTokenURL;
		{
			NSURLRequest *r = [[NSURLRequest alloc] initWithURL:
							   [NSURL  URLWithString:
								[NSString stringWithFormat:@"%@?client_id=%@&client_secret=%@&grant_type=%@&redirect_uri=%@&code=%@",
								 url,appKey,appSecret,@"authorization_code",redirectURI,code]]];
			NSURLResponse *resp = nil;
			NSError *err = nil;
			NSData *response = [NSURLConnection sendSynchronousRequest: r returningResponse: &resp error: &err];
			NSString * theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]; 
			NSLog(@"theString = %@",theString);
			
			NSString *access_token = [self getStringFromUrl:theString needle:@"access_token="];
			NSString *expires_in = [self getStringFromUrl:theString needle:@"expires_in="];
			NSString *refresh_token = [self getStringFromUrl:theString needle:@"refresh_token="];
			if ((access_token == (NSString *) [NSNull null]) || (access_token.length == 0)){
				if ([self respondsToSelector:@selector(request:didFailWithError:)]) {
					[self performSelector:@selector(request:didFailWithError:) withObject:request withObject:nil];
				}
			} else
			{
				if ([self respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
				
					[self performSelector:@selector(request:didFinishLoadingWithResult:) withObject:request withObject:[NSDictionary dictionaryWithObjectsAndKeys:access_token,@"access_token",
																													expires_in,@"expires_in",
																													self.qqOpenid,@"uid",nil]];
				}
			}
			[r release];
			
		}
		

		
		return;
		
		
	}
	else if([snsType isEqualToString:@"sina"])
	{
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
								appSecret, @"client_secret",
								@"authorization_code", @"grant_type",
								redirectURI, @"redirect_uri",
								code, @"code", nil];
		[request disconnect];
		NSLog(@"url = %@,params = %@",url,params);
		self.request = [WBRequest requestWithURL:url
                                   httpMethod:@"POST"
                                       params:params
                                 postDataType:kWBRequestPostDataTypeNormal
                             httpHeaderFields:nil 
                                     delegate:self];
    
		[request connect];
	}
}

- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
                                                                      appSecret, @"client_secret",
                                                                      @"password", @"grant_type",
                                                                      redirectURI, @"redirect_uri",
                                                                      userID, @"username",
                                                                      password, @"password", nil];
    
	
    if ([snsType isEqualToString:@"qq"]) {
        [params setValuesForKeysWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"response_type",@"token",
												@"type",@"user_agent",
												[NSString stringWithFormat:@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]],@"status_os",
												[[UIDevice currentDevice] name],@"status_machine",@"v2.0",@"status_version",nil]];
        
        NSArray *_permissions = [NSArray arrayWithObjects:
         @"get_user_info",@"add_share", @"add_topic",@"add_one_blog", @"list_album",
         @"upload_pic",@"list_photo", @"add_album", @"check_page_fans",nil];
        
        NSString* scope = [_permissions componentsJoinedByString:@","];
		[params setValue:scope forKey:@"scope"];
        
//        NSLog(@"%@",params);
    }
    
    [request disconnect];
    
    self.request = [WBRequest requestWithURL:kWBAccessTokenURL
                                   httpMethod:@"POST"
                                       params:params
                                 postDataType:kWBRequestPostDataTypeNormal
                             httpHeaderFields:nil 
                                     delegate:self];
    
    [request connect];
}

#pragma mark - WBAuthorize Public Methods

- (void)startAuthorize
{
    NSMutableDictionary *params ;
	
    if ([snsType isEqualToString:@"qq"]) {
		params = [NSMutableDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
				  redirectURI, @"redirect_uri",
				  @"code", @"response_type",
				  nil];
	}
	else if([snsType isEqualToString:@"sina"])
	{
		params =[NSMutableDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
		                                                                      @"code", @"response_type",
		                                                                      redirectURI, @"redirect_uri", 
		                                                                      @"mobile", @"display",@"1657944925",@"tid", nil];
		
	}
    
    NSString *url = kWBAuthorizeURL;
    if ([snsType isEqualToString:@"sina"]) {
        
    }
    else if ([snsType isEqualToString:@"qq"])
    {
        url = kQQAuthorizeURL;
    }
	NSLog(@"url = %@,params = %@",url,params);
    NSString *urlString = [WBRequest serializeURL:url
                                           params:params
                                       httpMethod:@"GET"];
    
//    NSLog(@"%@",urlString);
    
    WBAuthorizeWebView *webView = [[WBAuthorizeWebView alloc] init];
    [webView setDelegate:self];
    webView.snsType = self.snsType;
    [webView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [webView show:YES];
    [webView release];
}

- (void)startAuthorizeUsingUserID:(NSString *)userID password:(NSString *)password
{
    [self requestAccessTokenWithUserID:userID password:password];
}

#pragma mark - WBAuthorizeWebViewDelegate Methods

- (void)authorizeWebView:(WBAuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code withQQopenid:(NSString*)Openid
{
    [webView hide:YES];
    
	if(Openid!=nil)
		self.qqOpenid = Openid;
    // if not canceled
//    NSLog(@"%@",code);
    if (![code isEqualToString:@"21330"])
    {
        [self requestAccessTokenWithAuthorizeCode:code];
    }
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)theRequest didFinishLoadingWithResult:(id)result
{
    BOOL success = NO;
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        
        NSString *token = [dict objectForKey:@"access_token"];
        NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
		NSString *userID;
		if([snsType isEqualToString:@"sina"])
		{
			userID = [dict objectForKey:@"uid"];
        
			success = token && userID;
		}
		else if([snsType isEqualToString:@"qq"])
		{
			success = token && seconds;
			userID = self.qqOpenid;
		}
        
//        NSLog(@"%d",success);
        
        if (success && [delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)])
        {
            [delegate authorize:self didSucceedWithAccessToken:token userID:userID expiresIn:seconds];
        }
    }
    
    // should not be possible
    if (!success && [delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        NSError *error = [NSError errorWithDomain:kWBSDKErrorDomain 
                                             code:kWBErrorCodeSDK 
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kWBSDKErrorCodeAuthorizeError] 
                                                                              forKey:kWBSDKErrorCodeKey]];
        [delegate authorize:self didFailWithError:error];
    }
    
    
}

- (void)request:(WBRequest *)theReqest didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        [delegate authorize:self didFailWithError:error];
    }
    

}

@end
