

#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ChatCustomCell.h"


#define TOOLBARTAG		200
#define TABLEVIEWTAG	300

@implementation ChatViewController
@synthesize titleString = _titleString;
@synthesize chatArray = _chatArray;
@synthesize chatTableView = _chatTableView;
@synthesize messageTextField = _messageTextField;
@synthesize phraseViewController = _phraseViewController;
@synthesize isEdit = _isEdit;
@synthesize udpSocket = _udpSocket;
@synthesize messageString = _messageString;
@synthesize phraseString = _phraseString;
@synthesize lastTime = _lastTime;
@synthesize deleteArrary = _deleteArrary;
@synthesize isFromNewSMS = _isFromNewSMS;

@synthesize myIP;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSString *ip_iphone = [self deviceIPAdress];
    self.myIP = ip_iphone;
    NSLog(@"myIp--->%@",myIP);
	self.phraseViewController.chatViewController = self;
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑"
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:@selector(toggleEdit:)];
	self.navigationItem.rightBarButtonItem = rightItem;
	[rightItem release];
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.chatArray = tempArray;
	[tempArray release];
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	self.deleteArrary = array;
	[array release];
	
	NSDate   *tempDate = [[NSDate alloc] init];
	self.lastTime = tempDate;
	[tempDate release];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	
    self.titleString = @"即时通信";
	self.title = self.titleString;
	self.isEdit = NO;
	[self.messageTextField becomeFirstResponder];
	[self openUDPServer];
	
	[self.messageTextField setText:self.phraseString];
	if (self.isFromNewSMS) 
		[self initChatInfoFromNewSMS:self.messageString];
	
	[self.chatTableView reloadData];
}

-(void)initChatInfoFromNewSMS:(NSString *)message
{
	[self sendMassage:message];
}

//建立基于UDP的Socket连接
-(void)openUDPServer{
	//初始化udp
	AsyncUdpSocket *tempSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
	self.udpSocket=tempSocket;
	[tempSocket release];
	//绑定端口
	NSError *error = nil;
	[self.udpSocket bindToPort:4333 error:&error];
    
    //发送广播设置
    [self.udpSocket enableBroadcast:YES error:&error];
    
    //加入群里，能接收到群里其他客户端的消息
    [self.udpSocket joinMulticastGroup:@"224.0.0.2" error:&error];
    
   	//启动接收线程
	[self.udpSocket receiveWithTimeout:-1 tag:0];
  
}
//发送消息
-(IBAction)sendMessage_Click:(id)sender
{	
	NSString *messageStr = self.messageTextField.text;
	[self sendMassage:messageStr];
	self.messageTextField.text = @"";
	[_messageTextField resignFirstResponder];
    [self moveViewDown];

}
//通过UDP,发送消息
-(void)sendMassage:(NSString *)message
{   
    
	NSDate *nowTime = [NSDate date];
	
	NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
	[sendString appendString:message];
	//开始发送
	BOOL res = [self.udpSocket sendData:[sendString dataUsingEncoding:NSUTF8StringEncoding] 
								 toHost:@"224.0.0.2" 
								   port:4333 
							withTimeout:-1 
	
                                   tag:0];
    

   	if (!res) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"发送失败"
													   delegate:self
											  cancelButtonTitle:@"取消"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval >5) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}	
	
	UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"me",nil), message] 
								   from:YES];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"text", @"self", @"speaker", chatView, @"view", nil]];
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] 
							  atScrollPosition:UITableViewScrollPositionBottom 
									  animated:YES];
}
//选择常用消息短语
-(IBAction)showPhraseInfo:(id)sender
{
	[self.messageTextField resignFirstResponder];
	if (self.phraseViewController == nil) {
		PhraseViewController *temp = [[PhraseViewController alloc] initWithNibName:@"PhraseViewController" bundle:nil];
		self.phraseViewController = temp;
		[temp release];
	}
	self.phraseViewController.isFromChatView = YES;
	[self presentModalViewController:self.phraseViewController animated:YES];
}
//编辑
-(IBAction)toggleEdit:(id)sender {
	[self.messageTextField resignFirstResponder];
	[self moveViewDown];

	if (self.isEdit){
		self.isEdit = NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
		
		for(int i = 0;i < [self.chatArray count];i ++){
			if ([[self.chatArray objectAtIndex:i] isKindOfClass:[NSDictionary class]]){
				ChatCustomCell *cell = (ChatCustomCell *)[self.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
				cell.deleteButton.hidden = YES;
				
				NSDictionary *chatInfo = [self.chatArray objectAtIndex:i];
				UIView *chatView = [chatInfo objectForKey:@"view"];
				if ([chatInfo objectForKey:@"speaker"] == @"other")
					chatView.frame = CGRectMake(0.0f, 0.0f,  chatView.frame.size.width, chatView.frame.size.height);
								
			}
		}
		[self deleteContentFromTableView];
		[UIView commitAnimations];
	}
    else{
		self.isEdit = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
		
		for(int i = 0;i < [self.chatArray count];i ++){
			if ([[self.chatArray objectAtIndex:i] isKindOfClass:[NSDictionary class]]){
				ChatCustomCell *cell = (ChatCustomCell *)[self.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
				cell.deleteButton.hidden = NO;
							
				NSDictionary *chatInfo = [self.chatArray objectAtIndex:i];
				UIView *chatView = [chatInfo objectForKey:@"view"];
				if ([chatInfo objectForKey:@"speaker"] == @"other")
					chatView.frame = CGRectMake(50.0f, 0.0f,  chatView.frame.size.width, chatView.frame.size.height);
				
			}
		}
		[UIView commitAnimations];
	}
	
}

//选择删除信息，将要删除的内容存入删除数组中
-(IBAction)deleteItemAction:(id)sender{
	NSInteger tag = [sender tag];
	NSDictionary *chatInfo = [self.chatArray objectAtIndex:tag];
	
	ChatCustomCell *cell = (ChatCustomCell *)[self.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
	
	if ([self.deleteArrary containsObject:chatInfo]) {
		[cell.deleteButton setImage:[UIImage imageNamed:@"UnSelected.png"] forState:UIControlStateNormal];
		[self.deleteArrary removeObject:chatInfo];
	}else {
		[cell.deleteButton setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
		[self.deleteArrary addObject:chatInfo];
	}
	
}
//将信息从cell中删除
-(void)deleteContentFromTableView
{
	for (NSDictionary *dic in self.deleteArrary) {
		[self.chatArray removeObject:dic];
	}
	
	for (int i=0; i<[self.chatArray count]-1; i++) {
		if ([[self.chatArray objectAtIndex:i] isKindOfClass:[NSDate class]]&&[[self.chatArray objectAtIndex:i+1] isKindOfClass:[NSDate class]]) 
			[self.chatArray removeObject:[self.chatArray objectAtIndex:i]];
	}
	
	if ([[self.chatArray lastObject] isKindOfClass:[NSDate class]]) 
		[self.chatArray removeLastObject];
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	self.deleteArrary = array;
	[array release];
	
	[self.chatTableView reloadData];
}
/*
 生成泡泡UIView
 */
#pragma mark -
#pragma mark Table view methods
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf {
	// build single chat bubble cell with given text
	UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
	returnView.backgroundColor = [UIColor clearColor];
	
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
	
	UIFont *font = [UIFont systemFontOfSize:13];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(150.0f, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
	
	UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(21.0f, 14.0f, size.width+10, size.height+10)];
	bubbleText.backgroundColor = [UIColor clearColor];
	bubbleText.font = font;
	bubbleText.numberOfLines = 0;
	bubbleText.lineBreakMode = UILineBreakModeWordWrap;
	bubbleText.text = text;
	
	bubbleImageView.frame = CGRectMake(0.0f, 14.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+20.0f);
	if(fromSelf)
		returnView.frame = CGRectMake(290.0f-bubbleText.frame.size.width, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
	else
		returnView.frame = CGRectMake(0.0f, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
	
	[returnView addSubview:bubbleImageView];
	[bubbleImageView release];
	[returnView addSubview:bubbleText];
	[bubbleText release];
	
	return [returnView autorelease];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
	self.isFromNewSMS = NO;
	[self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_deleteArrary release];
	[_lastTime release];
	[_phraseString release];
	[_messageString release];
	[_udpSocket release];
	[_phraseViewController release];
	[_messageTextField release];
	[_chatArray release];
	[_titleString release];
	[_chatTableView release];
    [super dealloc];
}
#pragma mark -
#pragma mark UDP Delegate Methods
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{   
    
    [self.udpSocket receiveWithTimeout:-1 tag:0];
    NSLog(@"host---->%@",host);
    
    
    //收到自己发的广播时不显示出来
    NSMutableString *tempIP = [NSMutableString stringWithFormat:@"::ffff:%@",myIP];
    if ([host isEqualToString:self.myIP]||[host isEqualToString:tempIP])
    {   
//        return YES;
    }
    
   	//接收到数据回调，用泡泡VIEW显示出来
	
	NSString *info=[[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding] autorelease];
	
    UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@:%@", host, info] 
								   from:NO];

	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:info, @"text", @"other", @"speaker", chatView, @"view", nil]];
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] 
							  atScrollPosition:UITableViewScrollPositionBottom 
									  animated:YES];
	//已经处理完毕
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	//无法发送时,返回的异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{   
	//无法接收时，返回异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

#pragma mark -
#pragma mark Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		return 30;
	}else {
		UIView *chatView = [[self.chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
		return chatView.frame.size.height+10;
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CommentCellIdentifier = @"CommentCell";
	ChatCustomCell *cell = (ChatCustomCell*)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatCustomCell" owner:self options:nil] lastObject];
	}
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		// Set up the cell...
		NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yy-MM-dd HH:mm"];
		NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:[self.chatArray objectAtIndex:[indexPath row]]]];
		[formatter release];
				
		[cell.dateLabel setText:timeString];
		cell.deleteButton.hidden = YES;

	}else {
		// Set up the cell...
		NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
		UIView *chatView = [chatInfo objectForKey:@"view"];
		
		cell.deleteButton.tag = [indexPath row];
		cell.deleteButton.frame = CGRectMake(20.0f, chatView.center.y - 10.0f, 29.0f, 29.0f);
		[cell.deleteButton addTarget:self action:@selector(deleteItemAction:) forControlEvents:UIControlEventTouchUpInside];
		
		[cell.contentView addSubview:chatView];
		
		if (self.isEdit) {
			if ([chatInfo objectForKey:@"speaker"] == @"other")
				chatView.frame = CGRectMake(50.0f, 0.0f,  chatView.frame.size.width, chatView.frame.size.height);
			cell.deleteButton.hidden = NO;
		}else {
			if ([chatInfo objectForKey:@"speaker"] == @"other")
				chatView.frame = CGRectMake(0.0f, 0.0f,  chatView.frame.size.width, chatView.frame.size.height);
			cell.deleteButton.hidden = YES;
		}

	}
    return cell;
}
#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark -
#pragma mark TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(textField == self.messageTextField)
	{
		[self moveViewUp];
	}
}

//当键盘出现时候上移坐标
-(void)moveViewUp
{
	UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
	toolbar.frame = CGRectMake(0.0f, 120.0f, 320.0f, 44.0f);
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 120.0f);
	if([self.chatArray count])
		[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] 
								  atScrollPosition:UITableViewScrollPositionBottom 
										  animated:YES];
}
//当键盘消失时候下移坐标
-(void)moveViewDown
{
	UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
	toolbar.frame = CGRectMake(0.0f, 372.0f, 320.0f, 44.0f);
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 372.0f);

}


//得到本机IP
-(NSString *) deviceIPAdress
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    return [NSString stringWithFormat:@"%s",ip_names[1]];
}

@end
