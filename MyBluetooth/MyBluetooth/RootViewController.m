//
//  RootViewController.m
//  MyBluetooth
//
//  Created by oudongjia on 13-4-10.
//  Copyright (c) 2013年 oudongjia. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()
-(void)sendText;

@end


NSString * const sendType					=@"sendType";
NSString * const bank						=@"kBank";
NSString * const cnumber					=@"kCardnumber";
NSString * const money						=@"kMoney";

@implementation RootViewController


@synthesize connect;
@synthesize disconnect;
@synthesize sendMessage;
@synthesize bluetoothState;

@synthesize textField;

//@synthesize currentSession;
//@synthesize picker;

@synthesize theBluetooch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)connectPressed:(id)sender
{

    [theBluetooch connect];
    
}


- (void)disconnectPressed:(id)sender
{
    [theBluetooch disConnect];
    isConnect = NO;
    [self fleshButtonState];
    
}
- (void)sendMessagePressed:(id)sender
{
    
    //[self sendImage];
    [self sendText];

    
}
-(void)fleshButtonState
{
    if(isConnect)
    {
        connect.enabled = NO;
        disconnect.enabled = YES;
        sendMessage.enabled = YES;
    }
    else{
        connect.enabled = YES;
        disconnect.enabled = NO;
        sendMessage.enabled = NO;

    }
}
-(void)CreateUI
{
    textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 200, 30)];
    //self.textField.text = strPhoneNO;
    self.textField.textAlignment = UITextAlignmentLeft;
    self.textField.returnKeyType = UIReturnKeyGo;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.borderStyle =  UITextBorderStyleRoundedRect;
    self.textField.delegate = self;
    connect= [UIButton buttonWithType:UIButtonTypeCustom];
    [connect setImage:[UIImage imageNamed:@"connect.png"] forState:UIControlStateNormal];//设置按钮图
    [connect setFrame:CGRectMake(100 + 5, 70, 60, 30)];
    [connect setBackgroundColor:[UIColor clearColor]];
    [connect addTarget:self action:@selector(connectPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    disconnect = [UIButton buttonWithType:UIButtonTypeCustom];
    [disconnect setImage:[UIImage imageNamed:@"disconnect.png"] forState:UIControlStateNormal];//设置按钮图
    [disconnect setFrame:CGRectMake(70, 70+40, 60, 60)];
    [disconnect setBackgroundColor:[UIColor clearColor]];
    [disconnect addTarget:self action:@selector(disconnectPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    sendMessage=[UIButton buttonWithType:UIButtonTypeCustom];
    [sendMessage setImage:[UIImage imageNamed:@"send.png"] forState:UIControlStateNormal];//设置按钮图
    [sendMessage setFrame:CGRectMake(150 + 5, 70+40, 60, 60)];
    [sendMessage setBackgroundColor:[UIColor clearColor]];
    [sendMessage addTarget:self action:@selector(sendMessagePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    

    bluetoothState = [[UILabel alloc] init];

    bluetoothState.frame = CGRectMake(50,230, 200.0, 24.0);//CGRectMake(60+(80+60)*j, 20+85+(130)*i, 60.0, 30.0);
    bluetoothState.text = @"未连接";
    [bluetoothState setBackgroundColor:[UIColor clearColor]];
    
    bluetoothState.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bluetoothState.font = [UIFont systemFontOfSize:14.0f];
    bluetoothState.textColor = [UIColor blackColor];
    bluetoothState.backgroundColor = [UIColor clearColor];
    bluetoothState.textAlignment = UITextAlignmentCenter;
    
    [self.view addSubview:textField];
    [self.view addSubview:connect];
    [self.view addSubview:disconnect];
    [self.view addSubview:sendMessage];
    [self.view addSubview:bluetoothState];
    isConnect = NO;
    [self fleshButtonState];
    

    
}

//发送数据
- (void) sendName
{
	
	NSDictionary * msg = [NSDictionary dictionaryWithObjectsAndKeys:
		   @"displayName", sendType,
		   theBluetooch.currentSession.displayName, @"displayName", nil];
	NSString * myString=[msg JSONRepresentation];
	NSLog(@"%@", myString);
	
	
	if (msg == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请确认发送的数据不为空" delegate:self
											  cancelButtonTitle:@"确定" otherButtonTitles:nil];
		[alert show];
        
	}
	else{
		NSData *myData = [myString dataUsingEncoding: NSUTF8StringEncoding];
        [self sendData:myData];
		NSLog(@"发送数据: %@" ,myString);
	}
}

-(void)sendText
{
    BOOL b = YES;
	
	if ([textField.text length] <= 0)  {
		b = NO;
		
	}
    NSDictionary *msg = nil;
    
	NSString *text = textField.text;
    
	
	
	msg = [NSDictionary dictionaryWithObjectsAndKeys:
           @"sendtext", sendType,
		   text, @"text",
           nil];
	NSString * myString=[msg JSONRepresentation];
	NSLog(@"%@", myString);
	
	
	if (!b) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请确认发送的数据不为空" delegate:self
                                               cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
		[alert show];
        
	}
	else{
		NSData* myData = [myString dataUsingEncoding: NSUTF8StringEncoding];
        [self sendData:myData];
		NSLog(@"发送数据: %@" ,myString);
	}
}

-(void)sendImage
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bg" ofType:@"png"];
   
    UIImage * image = [UIImage imageWithContentsOfFile:path];
    
    NSData *data = UIImagePNGRepresentation(image);//[UIImagePNGRepresentation:image];	
	
	if (!data) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请确认发送的数据不为空" delegate:self
                                               cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
		[alert show];
        
	}
	else{
        [self sendData:data];
    }

}
-(void)sendData:(NSData*)ndata
{
    [theBluetooch sendData:ndata];;
     
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self CreateUI];
    
    theBluetooch = [TheBluetoochManager defaultUserManager];
    [theBluetooch setDelegate:self];
	// Do any additional setup after loading the view.
}


#pragma mark -
#pragma mark TheBluetoochDelegate
-(void)bluetoothManager:(TheBluetoochManager*)manager peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state
{
    
    switch (state) {
		case GKPeerStateConnected:
            
            isConnect = YES;
            [self fleshButtonState];
			//NSLog(@"连接,diplayName = %@",session.displayName);
            bluetoothState.text = @"已连接";
            [self sendName];
			break;
		case GKPeerStateDisconnected:
            isConnect = NO;
            [self fleshButtonState];
			NSLog(@"连接断开");
            bluetoothState.text = @"未连接";

			break;
	}

    
}


-(void)bluetoothManagerPeerPickerControllerDidCancel:(TheBluetoochManager*)manager
{
    bluetoothState.text = @"未连接";
    
}



//方法功能：接受数据
-(void)bluetoothManager:(TheBluetoochManager*)manager receiveData:(NSData*)data fromPeer:(NSString*)peer context:(void*)context
{
    // Read the bytes in data and perform an application-specific action, then free the NSData object
    
    
	NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
    //receiverTextView.text =aStr;
	
	NSDictionary *ndata = [[aStr JSONValue] retain];
	
	NSLog(@"接受数据: %@", ndata);
    NSString* type = [ndata objectForKey:sendType];
    if([type isEqualToString:@"displayName"])
    {
        bluetoothState.text = [ndata objectForKey:@"displayName"];
    }
    else if([type isEqualToString:@"sendtext"])
    {
        NSString *text = [ndata objectForKey:@"text"];
        UIAlertView *alertView =[[[UIAlertView alloc]initWithTitle:@"消息通知" message:text
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil] autorelease];
        [alertView show];
    }
    else //if([type isEqualToString:@"senddata"])
    {
        UIImage *displayImag = [UIImage imageWithData:data];
    
        NSLog(@"Save photo to album");
        UIImageWriteToSavedPhotosAlbum(displayImag, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
	
	
	
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	UIAlertView *alert = nil;
	if (error != NULL)
    {
		// Show error message…
		alert = [[UIAlertView alloc]initWithTitle:@"图片保存失败" message:@"图片没有加入到你的相册"
                                         delegate:self
                                cancelButtonTitle:@"确定"
                                otherButtonTitles:nil];
		
    }
    else  // No errors
    {
		// Show message image successfully saved
		alert = [[UIAlertView alloc]initWithTitle:@"图片保存成功" message:@"图片已经加入到你的相册"
                                         delegate:self
                                cancelButtonTitle:@"确定"
                                otherButtonTitles:nil];
    }
	[alert show];
	[alert release];
	
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	
	return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField // return NO to disallow editing.
{
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField // became first responder
{
	[textField becomeFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
// called when 'return' key pressed. return NO to ignore.
{
	{
		[textField resignFirstResponder];
		//[self willGotoLogin];
	}
	
	return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
