

#import <UIKit/UIKit.h>

@class NewSMSViewController;
@class ChatViewController;

@interface PhraseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
	UITableView               *_uiTableView;
	NSMutableArray            *_phraseArray;
	//NewSMSViewController      *_newSMSViewController;
	ChatViewController        *_chatViewController;
	BOOL                      _isFromChatView;

}
@property (nonatomic, retain) IBOutlet UITableView      *uiTableView;
@property (nonatomic, retain) NSMutableArray            *phraseArray;
@property (nonatomic, retain) NewSMSViewController      *newSMSViewController;
@property (nonatomic, retain) ChatViewController        *chatViewController;
@property (nonatomic, assign) BOOL                      isFromChatView;

-(IBAction)dismissMyselfAction:(id)sender;

@end
