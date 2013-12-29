//
//  RecognitionController.m
//  Facebook and Twitter Voice Recognition
//
//  Created by Vignesh Raja on 11/8/13.
//  Copyright (c) 2013 Vignesh Raja. All rights reserved.
//

#import "RecognitionController.h"

//Manages voice recognition and valid commands ("Open Facebook",etc.)
//
@implementation RecognitionController
@synthesize recog;
@synthesize command;
@synthesize synth;
@synthesize key;
@synthesize sentence;


//Starts listening for commands
- (IBAction)start:(id)sender
{
    [synth startSpeakingString:@"Listening Started"];
    [recog startListening];
}

-(IBAction)speak:(id)sender{
    [synth startSpeakingString:[sentence stringValue]];
}

//Stops listening for commands
- (IBAction)stop:(id)sender {
    [recog stopListening];
    [synth startSpeakingString:@"Listening Stopped"];
}

//Initializes executable commands, NSSpeechRecognizer, and NSSpeechSynthesizer
- (id)init {
    self = [super init];
    if (self) {
        NSArray *cmds = [NSArray arrayWithObjects:@"Update Status",
                                                  @"How Many Friend Requests Do I Have",
                                                  @"What Are My Notifications",
                                                  @"Post Photo",
                                                  @"Compose Tweet",
                                                  @"Change Avatar",
                                                  @"Tweet Image",
                                                  nil];
        recog = [[NSSpeechRecognizer alloc] init];
        [recog setCommands:cmds];
        [recog setDelegate:self];
        synth = [[NSSpeechSynthesizer alloc] init];
        [synth setDelegate:self];
        NSString *voiceID =[[NSSpeechSynthesizer availableVoices] objectAtIndex:2];
        [synth setVoice:voiceID];
        
    }
    return self;
}

//Displays a textbox for getting information from a user
+ (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        NSAssert1(NO, @"Invalid input dialog button %lu", (unsigned long)button);
        return nil;
    }
}

//Displays file choosing dialog
+ (NSString *)sendFileButtonAction{
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        NSArray* files = [openDlg filenames];
        NSString* fileName = [files objectAtIndex:0];
        return fileName;
        
    }
    return NULL;
}

//When a command is recognized, execute the Twitter/FB python scripts with the correct arguments
- (void)speechRecognizer:(NSSpeechRecognizer *)sender
     didRecognizeCommand:(id)aCmd {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/Library/Frameworks/Python.framework/Versions/2.7/bin/python2.7"];
    NSArray *arguments;
    NSString *path = @"/Users/vigneshraja/Documents/College/Junior\ Year/First\ Semester/Programming\ Studio/Facebook\ Voice\ Recognition/Facebook\ Voice\ Recognition/scripts/";
    //Update Facebook status with text
    if ([(NSString *)aCmd isEqualToString:@"Update Status"]) {
        NSString *text = @"Enter The Status You Would Like To Post";
        [synth startSpeakingString:text];
        NSString *status = [RecognitionController input:@"Enter your status" defaultValue:@"status" ];
        arguments = [NSArray arrayWithObjects: [path stringByAppendingString:@"facebook_commands.py"], @"update_status", status, nil];
        [task setArguments: arguments];
        [task launch];
        text = @"Updating Status";
        [synth startSpeakingString:text];
        return;
        
    //Tells you how many friend requests a user has
    } else if ([(NSString *)aCmd isEqualToString:@"How Many Friend Requests Do I Have"]) {
        arguments = [NSArray arrayWithObjects: [path stringByAppendingString:@"facebook_commands.py"], @"get_friend_requests", nil];
        [task setArguments: arguments];
        NSPipe *pipe;
        pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        [task launch];
        NSData *data;
        data = [file readDataToEndOfFile];
        NSString *response =  [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        [synth startSpeakingString:response];
        return;
    
    //Reads out your most recent notification
    } else if ([(NSString *)aCmd isEqualToString:@"What Are My Notifications"]) {
        arguments = [NSArray arrayWithObjects: [path stringByAppendingString:@"facebook_commands.py"], @"get_recent_notification", nil];
        [task setArguments: arguments];
        NSPipe *pipe;
        pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        [task launch];
        NSData *data;
        data = [file readDataToEndOfFile];
        NSString *response =  [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        [synth startSpeakingString:response];
        return;
        
    //Uploads a photo to your FB timeline
    } else if ([(NSString *)aCmd isEqualToString:@"Post Photo"]) {
        NSString *text = @"Please Choose an Image File";
        [synth startSpeakingString:text];
        NSString *filePath = [RecognitionController sendFileButtonAction];
        text = @"Please Enter a Caption";
        [synth startSpeakingString:text];
        NSString *caption = [RecognitionController input:@"Enter your caption" defaultValue:@"caption" ];
        arguments = [NSArray arrayWithObjects: [path stringByAppendingString:@"facebook_commands.py"], @"upload_photo", caption, filePath, nil];
        [task setArguments: arguments];
        [task launch];
        text = @"Posting Photo and Caption";
        [synth startSpeakingString:text];
        return;
    
    //Sends a text tweet
    } else if ([(NSString *)aCmd isEqualToString:@"Compose Tweet"]) {
        NSString *text = @"Please Enter a Tweet";
        [synth startSpeakingString:text];
        NSString *tweet = [RecognitionController input:@"Enter your tweet" defaultValue:@"tweet" ];
        arguments = [NSArray arrayWithObjects: [path stringByAppendingString:@"twitter_commands.py"], @"send_tweet", tweet, nil];
        [task setArguments: arguments];
        [task launch];
        text = @"Posting Tweet";
        [synth startSpeakingString:text];
        return;
    
    //Changes Twitter avatar
    } else if ([(NSString *)aCmd isEqualToString:@"Change Avatar"]) {
        NSString *text = @"Please Choose an Image File";
        [synth startSpeakingString:text];
        NSString *filePath = [RecognitionController sendFileButtonAction];
        arguments = [NSArray arrayWithObjects: [path stringByAppendingString:@"twitter_commands.py"], @"update_avatar", filePath, nil];
        [task setArguments: arguments];
        [task launch];
        text = @"Updating Avatar";
        [synth startSpeakingString:text];
        return;
    
    //Sends an image tweet
    } else if ([(NSString *)aCmd isEqualToString:@"Tweet Image"]) {
        NSString *text = @"Please Choose an Image File";
        [synth startSpeakingString:text];
        text = @"Please Enter a Tweet";
        [synth startSpeakingString:text];
        NSString *filePath = [RecognitionController sendFileButtonAction];
        NSString *caption = [RecognitionController input:@"Enter your caption" defaultValue:@"caption" ];
        arguments = [NSArray arrayWithObjects: [path stringByAppendingString:@"twitter_commands.py"], @"tweet_image", filePath, caption, nil];
        [task setArguments: arguments];
        [task launch];
        text = @"Posting Tweet and Photo";
        [synth startSpeakingString:text];
        return;
    }
}
@end