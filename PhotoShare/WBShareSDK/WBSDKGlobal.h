//
//  WBSDKGlobal.h
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


#define kWBSDKErrorDomain           @"WeiBoSDKErrorDomain"
#define kWBSDKErrorCodeKey          @"WeiBoSDKErrorCodeKey"

#define kWBSDKAPIDomain             @"https://api.weibo.com/2/"
#define kQQSDKAPIDomain              @"https://open.t.qq.com/api/"//t/add_pic @"https://graph.qq.com/"

#define kWBAppkey @"2621282267"
#define kWBSecret @"96aa30911a57f9ceaca0c61841648d74"

#define kQQAppkey @"801249965"
#define kQQSecret @"53aceb91ce77627c5ea3030025e726cb" 

//DJ douban appkey
#define DOUBANAPPKEY @"0be04a2671ad0cb723a0de7355072625"//设置douban appkey
#define DOUBANAPPSECRET @"c5aff0e6f283c4d5"

//DJ wy appkey
#define WYAPPKEY @"B8hgB7Xl4ILDUHrp"  //设置163 appkey
#define WYAPPSECRET @"lcAch2Sm7xBn1tXIPb8uVXCttFe2OTXH"

//sina
#define kWBAuthorizeURL     @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL   @"https://api.weibo.com/oauth2/access_token"
//tx
#define kQQAuthorizeURL     @"https://open.t.qq.com/cgi-bin/oauth2/authorize"
#define kQQAccessTokenURL   @"https://open.t.qq.com/cgi-bin/oauth2/access_token"


typedef enum
{
	kWBErrorCodeInterface	= 100,
	kWBErrorCodeSDK         = 101,
}WBErrorCode;

typedef enum
{
	kWBSDKErrorCodeParseError       = 200,
	kWBSDKErrorCodeRequestError     = 201,
	kWBSDKErrorCodeAccessError      = 202,
	kWBSDKErrorCodeAuthorizeError	= 203,
}WBSDKErrorCode;