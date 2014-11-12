//
//  ViewController.m
//  Lost Characters
//
//  Created by Mobile Making on 11/11/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate, UIBarPositioningDelegate>

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


@end

@implementation RootViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    NSMutableArray *toolbarButtons = [self.bottomToolbar.items mutableCopy];
    [toolbarButtons removeObject:self.deleteButton];
    [self.bottomToolbar setItems:toolbarButtons];
    self.originalTopConstant = self.topTableViewConstraint.constant;

    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.moc = delegate.managedObjectContext;

    [self loadDB];

    if (self.characters.count == 0)
    {
        [self loadPlist];
    }

}


- (void)viewWillAppear:(BOOL)animated
{

    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:path animated:YES];

}

#pragma mark - table view delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.characters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *character = self.characters[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [character valueForKey:@"passenger"];
    cell.detailTextLabel.text = [character valueForKey:@"actor"];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    [self deleteCharacter];
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
    [self toggleEditing];

}

- (IBAction)onFilterButtonPressed:(UIBarButtonItem *)sender
{

    if (![self.view.subviews containsObject:self.filterBar])
    {
        [self.view addSubview:self.filterBar];
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat screenWidth = screenRect.size.width;
        self.filterBar.frame = CGRectMake(0, 64 , screenWidth, self.filterBar.frame.size.height);
        self.topTableViewConstraint.constant = 44;
    }
    else
    {
        [self.filterBar removeFromSuperview];
        self.topTableViewConstraint.constant = self.originalTopConstant;
    }

    [self.view layoutSubviews];

}

#pragma mark - helper methods

- (void)loadDB
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Character"];

    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"passenger" ascending:YES];
    request.sortDescriptors = @[sortByName];
//    request.predicate = [NSPredicate predicateWithFormat:@"age <= 150"];

    self.characters = [[self.moc executeFetchRequest:request error:nil] mutableCopy];
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
    [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

    [self.tableView reloadData];
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

- (IBAction)unwindSegue:(UIStoryboardSegue *)sender
{

    [self loadDB];

}

@end
