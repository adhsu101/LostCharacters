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

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate>

@property NSManagedObjectContext *moc;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *characters;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIToolbar *customToolbar;

@end

@implementation RootViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    NSMutableArray *toolbarButtons = [self.customToolbar.items mutableCopy];
    [toolbarButtons removeObject:self.deleteButton];
    [self.customToolbar setItems:toolbarButtons];

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

}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Smoke monster!";
}

#pragma mark - IBActions

- (IBAction)onEditButtonPressed:(UIBarButtonItem *)button
{
    NSMutableArray *toolbarButtons = [self.customToolbar.items mutableCopy];

    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO];
        button.title = @"Edit";
        [toolbarButtons addObject:self.addButton];
        [toolbarButtons removeObject:self.deleteButton];
        [self.customToolbar setItems:toolbarButtons animated:YES];

    }
    else
    {
        [self.tableView setEditing:YES];
        button.title = @"Cancel";
        [toolbarButtons addObject:self.deleteButton];
        [toolbarButtons removeObject:self.addButton];
        [self.customToolbar setItems:toolbarButtons animated:YES];

    }

}

- (IBAction)onDeleteButtonPressed:(UIBarButtonItem *)sender
{

}

#pragma mark - helper methods

- (void)loadDB
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Character"];

    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"passenger" ascending:YES];
    request.sortDescriptors = @[sortByName];
//    request.predicate = [NSPredicate predicateWithFormat:@"age <= 150"];

    self.characters = [self.moc executeFetchRequest:request error:nil];
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
