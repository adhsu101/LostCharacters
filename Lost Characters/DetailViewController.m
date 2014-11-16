//
//  DetailViewController.m
//  Lost Characters
//
//  Created by Mobile Making on 11/11/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *passengerTextField;
@property (strong, nonatomic) IBOutlet UITextField *actorTextField;
@property (strong, nonatomic) IBOutlet UITextField *akaTextField;
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) IBOutlet UITextField *originTextField;
@property (strong, nonatomic) IBOutlet UITextField *sigTextField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@property UIInputView *inputView;
@property (strong, nonatomic) IBOutlet UIPickerView *sigPicker;
@property NSArray *pickerList;
@property float screenWidth;
@property float screenHeight;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // prepopulate textfields if editing an existing character
    self.passengerTextField.text = [self.character valueForKey:@"passenger"];
    self.actorTextField.text = [self.character valueForKey:@"actor"];
    self.akaTextField.text = [self.character valueForKey:@"aka"];
    self.ageTextField.text = [self.character valueForKey:@"age"];
    self.originTextField.text = [self.character valueForKey:@"origin"];
    if (self.character)
    {
        self.sigTextField.text = [self.character valueForKey:@"significance"];
    }

    // custom picker input for significance attribute
    self.pickerList = @[@"Main Character", @"Supporting Character"];

    for (int i = 0; i < self.pickerList.count; i++)
    {
        if ([self.pickerList[i] isEqualToString:[self.character valueForKey:@"significance"]])
        {
            [self.sigPicker selectRow:i inComponent:0 animated:YES];
        }
    }

    self.sigTextField.inputView = self.sigPicker;
    
    // set cancel button
    self.cancelButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                   target:self
                                   action:@selector(onCancelButtonPressed:)];

    self.navigationItem.leftBarButtonItem = self.cancelButton;

}

#pragma mark - text field delegate methods

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    if ([textField isEqual:self.sigTextField])
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
//}

#pragma mark - picker view delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.sigTextField.text = self.pickerList[row];
    [self.sigTextField resignFirstResponder];
//    [self hidePicker];
}

#pragma mark - IBActions

- (IBAction)doneEditing:(UITextField *)sender
{
    [sender resignFirstResponder];
}

//- (IBAction)onSigTextFieldTapped:(UITextField *)sender
//{
//
//    if (self.sigPicker.frame.origin.y == self.screenHeight)
//    {
//
//        [self showPicker];
//
//    }
//    else
//    {
//
//        [self hidePicker];
//
//    }
//
//}

- (IBAction)onCancelButtonPressed:(UINavigationItem *)sender
{

    if (self.character == nil)
    {
         [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
//        [self.sigPicker removeFromSuperview];
    }

}

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

    [self.character setValue:self.sigTextField.text forKey:@"significance"];

    [self.moc save:nil];

    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.sigPicker removeFromSuperview];

}

#pragma mark - helper methods

//- (void)showPicker
//{
//
//    [UIView animateWithDuration:0.2 animations:^{
//
//        float y = self.screenHeight - self.sigPicker.frame.size.height;
//        [self.sigPicker setFrame:CGRectMake(0, y, self.screenWidth, self.sigPicker.frame.size.height)];
//
//    }];
//}
//
//- (void)hidePicker
//{
//    [UIView animateWithDuration:0.2 animations:^{
//
//        [self.sigPicker setFrame:CGRectMake(0, self.screenHeight, self.screenWidth, self.sigPicker.frame.size.height)];
//
//    }];
//}

#pragma mark - navigation


@end
