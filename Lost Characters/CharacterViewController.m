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

@interface CharacterViewController () <UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate, UIBarPositioningDelegate>

@property NSManagedObjectContext *moc;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *characters;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIToolbar *filterBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topTableViewConstraint;
@property NSInteger originalTopConstant;
@property (strong, nonatomic) IBOutlet UITextField *filterTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *filterSegmentedControl;
@property CGRect hiddenFrame;
@property CGRect notHiddenFrame;


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

    [self loadDB];

    if (self.characters.count == 0)
    {
        [self loadPlist];
    }

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
    cell.avatarView.image = [UIImage imageNamed:@"lost"];
    cell.actorLabel.text = [character valueForKey:@"actor"];
    cell.akaLabel.text = [character valueForKey:@"aka"];
    cell.originLabel.text = [character valueForKey:@"origin"];
    cell.ageLabel.text = [character valueForKey:@"age"];

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

- (void)hideFilterBar
{

    [UIView animateWithDuration:0.2 animations:^{

        self.topTableViewConstraint.constant = self.originalTopConstant;
        self.filterBar.frame = self.hiddenFrame;
        self.filterBar.alpha = 0.0;
        [self.view layoutIfNeeded];

    }];

}

- (void)showFilterBar
{
    [UIView animateWithDuration:0.2 animations:^{
        
        self.topTableViewConstraint.constant = self.topTableViewConstraint.constant + self.filterBar.frame.size.height;
        self.filterBar.frame = self.notHiddenFrame;
        self.filterBar.alpha = 1.0;
        [self.view layoutIfNeeded];
        
    }];
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
    
    if (self.characters.count <= 1)
    {
        self.filterButton.enabled = NO;
        [self hideFilterBar];
    }
    else
    {
        self.filterButton.enabled = YES;
    }
}

- (void)loadDB
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Character"];

    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"passenger" ascending:YES];
    request.sortDescriptors = @[sortByName];
//    request.predicate = [NSPredicate predicateWithFormat:@"age <= 150"];

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

    [self loadDB];

}

- (void)toggleEditing
{

    NSMutableArray *toolbarButtons = [self.bottomToolbar.items mutableCopy];

    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO];
        self.editButton.title = @"Edit";
        [toolbarButtons addObject:self.addButton];
        [toolbarButtons removeObject:self.deleteButton];
        [self.bottomToolbar setItems:toolbarButtons animated:YES];

    }
    else
    {
        [self.tableView setEditing:YES];
        self.editButton.title = @"Cancel";
        [toolbarButtons addObject:self.deleteButton];
        [toolbarButtons removeObject:self.addButton];
        [self.bottomToolbar setItems:toolbarButtons animated:YES];

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

    DetailViewController *vc = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"editSegue"])
    {

        vc.character = self.characters[[self.tableView indexPathForSelectedRow].row];

    }

    vc.moc = self.moc;
    
}

//- (IBAction)unwindSegue:(UIStoryboardSegue *)sender
//{
//
//    [self loadDB];
//
//}

@end
