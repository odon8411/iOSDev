
#import <UIKit/UIKit.h>
#import "PhraseViewController.h"
#import "AsyncUdpSocket.h"
#import "IPAddress.h"

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate> {
	NSString                   *_titleString;
	NSString                   *_messageString;
	NSString                   *_phraseString;
	NSMutableArray		       *_chatArray;
	NSMutableArray             *_deleteArrary;
	
	UITableView                *_chatTableView;
	UITextField                *_messageTextField;
	BOOL				       _isEdit;
	BOOL                       _isFromNewSMS;
	PhraseViewController       *_phraseViewController;
	
	AsyncUdpSocket             *_udpSocket;
	
	NSDate                     *_lastTime;
}
@property (nonatomic, retain) IBOutlet PhraseViewController   *phraseViewController;
@property (nonatomic, retain) IBOutlet UITableView            *chatTableView;
@property (nonatomic, retain) IBOutlet UITextField            *messageTextField;
@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSString               *titleString;
@property (nonatomic, retain) NSString               *messageString;
@property (nonatomic, retain) NSMutableArray		 *chatArray;
@property (nonatomic, retain) NSMutableArray		 *deleteArrary;

@property (nonatomic, assign) BOOL					 isEdit;
@property (nonatomic, assign) BOOL                   isFromNewSMS;
@property (nonatomic, retain) NSDate                 *lastTime;
@property (nonatomic, retain) AsyncUdpSocket         *udpSocket;


@property (nonatomic, retain) NSString *myIP;

-(IBAction)sendMessage_Click:(id)sender;
-(IBAction)toggleEdit:(id)sender;
-(IBAction)deleteItemAction:(id)sender;
-(IBAction)showPhraseInfo:(id)sender;

-(void)moveViewUp;
-(void)moveViewDown;
-(void)openUDPServer;
-(void)initChatInfoFromNewSMS:(NSString *)message;
-(void)sendMassage:(NSString *)message;
-(void)deleteContentFromTableView;

- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf;

-(NSString *) deviceIPAdress;

@end
