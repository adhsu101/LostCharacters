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
@property (strong, nonatomic) IBOutlet UIView *textFieldBorder;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.passengerTextField.text = [self.character valueForKey:@"passenger"];
    self.actorTextField.text = [self.character valueForKey:@"actor"];
    self.akaTextField.text = [self.character valueForKey:@"aka"];
    self.ageTextField.text = [self.character valueForKey:@"age"];
    self.originTextField.text = [self.character valueForKey:@"origin"];

}

#pragma mark - IBActions

- (IBAction)onSaveButtonPressed:(UIButton *)sender
{
    if (self.character == nil && ![self.passengerTextField.text isEqualToString:@""])
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

    [self.moc save:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
