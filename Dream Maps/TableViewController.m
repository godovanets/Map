
#import "LocationManager.h"
#import "MapViewController.h"
#import "TableViewController.h"

@interface TableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(weak, nonatomic) IBOutlet UITableView *locationTableView;
@property(nonatomic) NSInteger selectedLocationIndex;

#pragma mark - Properties for adding new location

@property(strong, nonatomic) NSString *addedLocationName;
@property(strong, nonatomic) NSString *addedLocationAdress;
@property(strong, nonatomic) NSNumber *addedlocationLatitude;
@property(strong, nonatomic) NSNumber *addedlocationLongtitude;
@property(strong, nonatomic) NSString *addedlocationDescription;
@property BOOL isNewLocationDataProvided;

#pragma mark - Property for Data Model


@end

static NSString *kLocationsList =
    @"locationsList";  // for saving data with NSUserDefaults

@implementation TableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // add edit button
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  [self.editButtonItem setTintColor:[UIColor blueColor]];

  // add + button
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                           target:self
                           action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItem = addButton;
  [addButton setTintColor:[UIColor blueColor]];


  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(receiveNotification:)
             name:@"myNotification"
           object:nil];

 }

#pragma mark - Recieve notifications from MapViewController

- (void)receiveNotification:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"myNotification"]) {
    LocationManager *recievedLocation = (LocationManager *)notification.object;
    self.addedLocationName = recievedLocation.locationName;
    self.addedLocationAdress = recievedLocation.locationAdress;
    self.addedlocationLatitude = recievedLocation.locationLatitude;
    self.addedlocationLongtitude = recievedLocation.locationLongtitude;
    self.addedlocationDescription = recievedLocation.locationDescription;

    [self submitNewLocation];

    NSLog(@"Notification recieved and new location added to table");
  }
}

#pragma mark - Editing table cell

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableview
    shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (BOOL)tableView:(UITableView *)tableview
    canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView
    moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
           toIndexPath:(NSIndexPath *)destinationIndexPath {
  LocationManager *locationToMove = _locationsList[sourceIndexPath.row];
  [_locationsList removeObjectAtIndex:sourceIndexPath.row];
  [_locationsList insertObject:locationToMove atIndex:destinationIndexPath.row];
}

- (NSArray *)tableView:(UITableView *)tableView
    editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewRowAction *editAction =
      [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                         title:@"Modify"
                                       handler:^(UITableViewRowAction *action,
                                                 NSIndexPath *indexPath) {

                                         [self manageLocationShowBox:indexPath
                                               andTypeOfModification:@"modify"];

                                       }];
  editAction.backgroundColor = [UIColor orangeColor];

  UITableViewRowAction *deleteAction = [UITableViewRowAction
      rowActionWithStyle:UITableViewRowActionStyleNormal
                   title:@"Delete"
                 handler:^(UITableViewRowAction *action,
                           NSIndexPath *indexPath) {

                   [self tableView:self.locationTableView
                       commitEditingStyle:UITableViewCellEditingStyleDelete
                        forRowAtIndexPath:indexPath];

                 }];
  deleteAction.backgroundColor = [UIColor redColor];

  return @[ deleteAction, editAction ];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  [super setEditing:editing animated:animated];
  [self.locationTableView setEditing:editing animated:animated];
}

- (void)manageLocationShowBox:(NSIndexPath *)atIndex
        andTypeOfModification:(NSString *)modificationType {
  UIAlertController *alert;

  if ([modificationType isEqualToString:@"insert"]) {
    alert = [UIAlertController
        alertControllerWithTitle:@"Add new location"
                         message:@"Please provide some description of location "
                                 @"you want to add"
                  preferredStyle:UIAlertControllerStyleAlert];
  } else if ([modificationType isEqualToString:@"modify"]) {
    alert = [UIAlertController
        alertControllerWithTitle:@"Edit location"
                         message:@"Please provide new data"
                  preferredStyle:UIAlertControllerStyleAlert];
  }

  [alert addAction:[UIAlertAction
                       actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                 NSLog(@"%@ cancel button tap recognized",
                                       modificationType);

                               }]];

  [alert addAction:[UIAlertAction
                       actionWithTitle:@"Submit"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                 NSLog(@"%@ submit button tap recognized",
                                       modificationType);

                                 NSLog(@"%@",
                                       [alert.textFields objectAtIndex:0].text);
                                 self.addedLocationName =
                                     [alert.textFields objectAtIndex:0].text;

                                 NSLog(@"%@",
                                       [alert.textFields objectAtIndex:1].text);
                                 self.addedLocationAdress =
                                     [alert.textFields objectAtIndex:1].text;

                                 NSLog(@"%@",
                                       [alert.textFields objectAtIndex:2].text);
                                 self.addedlocationLatitude = [NSNumber
                                     numberWithDouble:[alert.textFields
                                                          objectAtIndex:2]
                                                          .text.doubleValue];

                                 NSLog(@"%@",
                                       [alert.textFields objectAtIndex:3].text);
                                 self.addedlocationLongtitude = [NSNumber
                                     numberWithDouble:[alert.textFields
                                                          objectAtIndex:3]
                                                          .text.doubleValue];

                                 NSLog(@"%@",
                                       [alert.textFields objectAtIndex:4].text);
                                 self.addedlocationDescription =
                                     [alert.textFields objectAtIndex:4].text;

                                 if ([modificationType
                                         isEqualToString:@"insert"]) {
                                   [self submitNewLocation];
                                 } else if ([modificationType
                                                isEqualToString:@"modify"]) {
                                   [self updateLocationAtIndex:atIndex];
                                 }

                               }]];

  [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Enter location name";
    textField.secureTextEntry = NO;
  }];
  [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Enter location adress";
    textField.secureTextEntry = NO;
  }];
  [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Enter location latitude";
    textField.secureTextEntry = NO;
  }];
  [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Enter location longtitude";
    textField.secureTextEntry = NO;
  }];
  [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Enter location description (optional)";
    textField.secureTextEntry = NO;
  }];

  [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateLocationAtIndex:(NSIndexPath *)index {
  [self.locationTableView beginUpdates];

  [_locationsList
      replaceObjectAtIndex:[index row]
                withObject:
                    [LocationManager
                        newLocationWithName:self.addedLocationName
                                  andAdress:self.addedLocationAdress
                             andDescription:self.addedlocationDescription
                                andLatitude:self.addedlocationLatitude
                              andLongtitude:self.addedlocationLongtitude]];
  [self.locationTableView endUpdates];
  [self.locationTableView reloadData];

  NSLog(@"Location updated");
}

#pragma mark - Adding new locations to table

- (void)insertNewObject:(id)sender {
  [self manageLocationShowBox:nil andTypeOfModification:@"insert"];
}

- (void)submitNewLocation {
  if (!_locationsList) {
    _locationsList = [NSMutableArray array];
  }

  [_locationsList
      insertObject:[LocationManager
                       newLocationWithName:self.addedLocationName
                                 andAdress:self.addedLocationAdress
                            andDescription:self.addedlocationDescription
                               andLatitude:self.addedlocationLatitude
                             andLongtitude:self.addedlocationLongtitude]
           atIndex:0];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  [self.locationTableView
      insertRowsAtIndexPaths:@[ indexPath ]
            withRowAnimation:UITableViewRowAnimationAutomatic];
  NSLog(@"Location added");
}

#pragma mark - Table delegate's methods

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [_locationsList removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationFade];
  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array,
    // and add a new row to the table view.
  }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    // Initialize the array of monsters for display.
    _locationsList = [NSMutableArray array];

    // Create location objects then add them to the array.

    [_locationsList
        addObject:[LocationManager newLocationWithName:@"Apple 1 Infinity Loop"
                                             andAdress:@"CA, USA"
                                        andDescription:@"Apple Campus"
                                           andLatitude:@37.331402
                                         andLongtitude:@-122.030398]];

    [_locationsList
        addObject:[LocationManager newLocationWithName:@"Niagara Falls"
                                             andAdress:@"NY, United States"
                                        andDescription:@"Niagara Falls"
                                           andLatitude:@43.084943
                                         andLongtitude:@-79.061272]];

    [_locationsList
        addObject:[LocationManager newLocationWithName:@"Eifel Tower"
                                             andAdress:@"Paris, FR"
                                        andDescription:@"Eifel Tower"
                                           andLatitude:@48.858405
                                         andLongtitude:@2.294492]];

    [_locationsList
        addObject:[LocationManager newLocationWithName:@"Empire State Building"
                                             andAdress:@"New York, NY 10118"
                                        andDescription:@"Empire State Building"
                                           andLatitude:@40.748448
                                         andLongtitude:@-73.985686]];
  }

  return self;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  // NSLog(@"Count of locations: %lu", _locationsList.count);
  return _locationsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *locationsTableIdentifier = @"locationTableCell";

  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:locationsTableIdentifier];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:locationsTableIdentifier];
  }

  LocationManager *location = _locationsList[indexPath.row];

  cell.textLabel.text = location.locationName;
  cell.detailTextLabel.text = location.locationDescription;

  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  [cell setBackgroundColor:[UIColor clearColor]];

  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.selectedLocationIndex = indexPath.row;

  if (UIInterfaceOrientationIsPortrait(
          (UIInterfaceOrientation)[UIDevice currentDevice].orientation)) {
    [UIView animateWithDuration:0.20
        animations:^{
          self.splitViewController.preferredDisplayMode =
              UISplitViewControllerDisplayModePrimaryHidden;
        }
        completion:^(BOOL finished) {
          self.splitViewController.preferredDisplayMode =
              UISplitViewControllerDisplayModeAutomatic;
        }];
  }

  [self performSegueWithIdentifier:@"showDetail" sender:self];
}

#pragma mark - Segue to MapViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    MapViewController *controller =
        (MapViewController *)[segue destinationViewController];

    [controller setLocation:[self.locationsList
                                objectAtIndex:self.selectedLocationIndex]];
  }
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];

  [[self.view.superview.superview.superview.superview.superview.superview
           .subviews objectAtIndex:0]
          .subviews objectAtIndex:0]
      .alpha = 0.0;
}

@end
