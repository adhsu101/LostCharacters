//
//  DetailViewController.m
//  Lost Characters
//
//  Created by Mobile Making on 11/11/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UITextField *passengerTextField;
@property (strong, nonatomic) IBOutlet UITextField *actorTextField;
@property (strong, nonatomic) IBOutlet UITextField *akaTextField;
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) IBOutlet UITextField *originTextField;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    if (self.character != nil)
//    {

        self.passengerTextField.placeholder = [self.character valueForKey:@"passenger"];
        self.actorTextField.placeholder = [self.character valueForKey:@"actor"];
        self.akaTextField.placeholder = [self.character valueForKey:@"aka"];
        self.ageTextField.placeholder = [self.character valueForKey:@"age"];
        self.originTextField.placeholder = [self.character valueForKey:@"origin"];

//    }

}

#pragma mark - IBActions

- (IBAction)onSaveButtonPressed:(UIButton *)sender
{
    if (self.character == nil)
    {
        NSManagedObject *newCharacter = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.moc];
        self.character = newCharacter;
    }

    if (![self.passengerTextField.text isEqualToString:@""])
    {
        [self.character setValue:self.passengerTextField.text forKey:@"passenger"];
    }

    if (![self.actorTextField.text isEqualToString:@""])
    {
        [self.character setValue:self.actorTextField.text forKey:@"actor"];
    }

    if (![self.akaTextField.text isEqualToString:@""])
    {
        [self.character setValue:self.akaTextField.text forKey:@"aka"];
    }

    if (![self.ageTextField.text isEqualToString:@""])
    {
        [self.character setValue:self.ageTextField.text forKey:@"age"];
    }

    if (![self.originTextField.text isEqualToString:@""])
    {
        [self.character setValue:self.originTextField.text forKey:@"origin"];
    }
}

@end
