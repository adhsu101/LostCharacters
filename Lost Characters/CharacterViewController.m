//
//  ViewController.m
//  Lost Characters
//
//  Created by Mobile Making on 11/11/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "CharacterViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "CharacterTableViewCell.h"
#define kFilterBarOffsetFromTopLayout 64

@interface CharacterViewController () <UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate, UIBarPositioningDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property NSManagedObjectContext *moc;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *characters;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIToolbar *filterBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *filterToggle;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topTableViewConstraint;
@property NSInteger originalTopConstant;

@property (strong, nonatomic) IBOutlet UISegmentedControl *filterSegmentedControl;
@property CGRect hiddenFrame;
@property CGRect notHiddenFrame;

@property NSIndexPath *indexPathForAvatar;
@property UIImagePickerController *imagePicker;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPress;

@end

@implementation CharacterViewController

- (void)viewDidLoad
{

    [super viewDidLoad];

    NSMutableArray *toolbarButtons = [self.bottomToolbar.items mutableCopy];
    [toolbarButtons removeObject:self.deleteButton];
    [self.bottomToolbar setItems:toolbarButtons];
    self.originalTopConstant = self.topTableViewConstraint.constant;

    // set filter bar
    [self.view addSubview:self.filterBar];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = screenRect.size.width;
    self.hiddenFrame = CGRectMake(0, kFilterBarOffsetFromTopLayout - self.filterBar.frame.size.height, screenWidth, self.filterBar.frame.size.height);
    self.notHiddenFrame = CGRectMake(0, kFilterBarOffsetFromTopLayout, screenWidth, self.filterBar.frame.size.height);

    self.filterBar.frame = self.hiddenFrame;
    self.filterBar.alpha = 0.0;

    // set moc
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.moc = delegate.managedObjectContext;

}


- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:path animated:YES];

    // refresh screen

    [self hideFilterBar];

    if (self.characters.count == 0)
    {
        [self loadPlist];
    }

}

- (void)viewDidLayoutSubviews
{
}

#pragma mark - table view delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.characters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *character = self.characters[indexPath.row];
    CharacterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.characterLabel.text = [character valueForKey:@"passenger"];
    if ([character valueForKey:@"image"] == nil)
    {
        cell.avatarView.image = [UIImage imageNamed:@"lost"];
    }
    else
    {
        cell.avatarView.image = [UIImage imageWithData:[character valueForKey:@"image"]];
    }
    cell.actorLabel.text = [character valueForKey:@"actor"];
    cell.akaLabel.text = [character valueForKey:@"aka"];
    cell.originLabel.text = [character valueForKey:@"origin"];
    cell.ageLabel.text = [character valueForKey:@"age"];
    if ([[character valueForKey:@"significance"] isEqualToString:@"Supporting Character"])
    {
        cell.sigLabel.text = @"SUPPORTING";
    }
    else
    {
        cell.sigLabel.text = @"MAIN";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self deleteCharacter];
    [self checkEmpty];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Smoke monster!";
}

#pragma mark - image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    CharacterTableViewCell *cell = (CharacterTableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathForAvatar];
    cell.avatarView.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];

    NSManagedObject *character = self.characters[self.indexPathForAvatar.row];
    [character setValue:UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]) forKey:@"image"];

    [self.moc save:nil];

    [self.tableView reloadData];

}

#pragma mark - gesture recognizer methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{

    self.indexPathForAvatar = [self.tableView indexPathForCell:(UITableViewCell *)[gestureRecognizer.view superview].superview];

    self.longPress = (UILongPressGestureRecognizer *)gestureRecognizer;

    return YES;

}


#pragma mark - Action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex) {
        case 0:
        {

            self.imagePicker = [[UIImagePickerController alloc] init];
            self.imagePicker.delegate = self;

            self.imagePicker.allowsEditing = YES;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

            [self presentViewController:self.imagePicker animated:YES completion:nil];

            break;
        }
            case 1:
        {

            NSManagedObject *character = self.characters[self.indexPathForAvatar.row];

            [character setValue:nil forKey:@"image"];
            [self.moc save:nil];
            CharacterTableViewCell *cell = (CharacterTableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathForAvatar];
            cell.avatarView.image = [UIImage imageNamed:@"lost"];

            break;
        }

        default:
            break;
    }

}

#pragma mark - IBActions

- (IBAction)onEditButtonPressed:(UIBarButtonItem *)button
{

    [self toggleEditing];

}


- (IBAction)onDeleteButtonPressed:(UIBarButtonItem *)sender
{

    [self deleteCharacter];
    [self checkEmpty];
    [self toggleEditing];

}

- (IBAction)onFilterButtonPressed:(UIBarButtonItem *)sender
{

    if (self.filterBar.alpha == 0.0)
    {

        [self showFilterBar];

    }
    else
    {

        [self hideFilterBar];

    }

    [self.view layoutSubviews];

}

- (IBAction)onFiltered:(UISegmentedControl *)sender
{
    if ([sender selectedSegmentIndex] == 0)
    {
        [self loadDB:@"Main Character"];
    }
    else
    {
        [self loadDB:@"Supporting Character"];
    }
}

- (IBAction)onImageLongPressed:(UILongPressGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.tableView];
    self.indexPathForAvatar = [self.tableView indexPathForRowAtPoint:location];

    if (self.longPress.state == UIGestureRecognizerStateBegan)
    {
        UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose avatar", @"Remove avatar", nil];
        chooseImageSheet.destructiveButtonIndex = 1;
        [chooseImageSheet showInView:self.view];
    }

}

#pragma mark - helper methods

- (void)checkEmpty
{

    if (self.characters.count == 0)
    {
        self.editButton.enabled = NO;
    }
    else
    {
        self.editButton.enabled = YES;
    }
    
}

- (void)loadDB:(NSString *)significance
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Character"];

    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"passenger" ascending:YES];
    request.sortDescriptors = @[sortByName];

    request.predicate = [NSPredicate predicateWithFormat:@"significance like %@", significance];

    self.characters = [[self.moc executeFetchRequest:request error:nil] mutableCopy];

    [self checkEmpty];

    [self.tableView reloadData];
    
}

- (void)loadPlist
{

    NSString* path = [[NSBundle mainBundle] pathForResource:@"lost"
                                                     ofType:@"plist"];
    NSURL *plistURL = [NSURL fileURLWithPath:path];

    NSArray *charactersFromPlist = [NSArray arrayWithContentsOfURL:plistURL];

    for (NSDictionary *d in charactersFromPlist)
    {
        NSManagedObject *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.moc];
        [character setValue:d[@"actor"] forKey:@"actor"];
        [character setValue:d[@"passenger"] forKey:@"passenger"];

        [self.moc save:nil];
    }

    [self loadDB:@"*"];

}

- (void)toggleEditing
{

    NSMutableArray *toolbarButtons = [self.bottomToolbar.items mutableCopy];

    if ([self.tableView isEditing])
    {
        [UIView animateWithDuration:0.2 animations:^{

            [self.tableView setEditing:NO];
            self.editButton.title = @"Edit";
            [toolbarButtons addObject:self.addButton];
            [toolbarButtons removeObject:self.deleteButton];
            [self.bottomToolbar setItems:toolbarButtons animated:YES];

        }];

    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{

            [self.tableView setEditing:YES];
            self.editButton.title = @"Cancel";
            [toolbarButtons addObject:self.deleteButton];
            [toolbarButtons removeObject:self.addButton];
            [self.bottomToolbar setItems:toolbarButtons animated:YES];

        }];

    }

}

- (void)deleteCharacter
{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];

    for (NSIndexPath *i in selectedIndexPaths)
    {
        NSManagedObject *deletedCharacter = self.characters[i.row];
        [self.moc deleteObject:deletedCharacter];
        [self.moc save:nil];
    }

    NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
    for (NSIndexPath *selectionIndex in selectedIndexPaths)
    {
        [indicesOfItemsToDelete addIndex:selectionIndex.row];
    }
    // Delete the objects from our data model.

    [self.characters removeObjectsAtIndexes:indicesOfItemsToDelete];

    // Tell the tableView that we deleted the objects
    [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationTop];

}

- (void)hideFilterBar
{

    [UIView animateWithDuration:0.2 animations:^{

        self.topTableViewConstraint.constant = self.originalTopConstant;
        self.filterBar.frame = self.hiddenFrame;
        self.filterBar.alpha = 0.0;
        [self.view layoutIfNeeded];

    }];

    [self loadDB:@"*"];

}

- (void)showFilterBar
{

    [UIView animateWithDuration:0.2 animations:^{

        self.topTableViewConstraint.constant = self.topTableViewConstraint.constant + self.filterBar.frame.size.height;
        self.filterBar.frame = self.notHiddenFrame;
        self.filterBar.alpha = 1.0;
        [self.view layoutIfNeeded];
        
    }];

    [self onFiltered:self.filterToggle];
}

#pragma mark - segue life cycle

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([self.tableView isEditing])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    DetailViewController *vc = [[DetailViewController alloc] init];

    if ([segue.identifier isEqualToString:@"editSegue"])
    {
        vc = segue.destinationViewController;
        vc.character = self.characters[[self.tableView indexPathForSelectedRow].row];
    }
    else
    {
        UINavigationController *navVC = segue.destinationViewController;
        vc = navVC.childViewControllers.firstObject;
    }

    vc.moc = self.moc;
    
}

@end
