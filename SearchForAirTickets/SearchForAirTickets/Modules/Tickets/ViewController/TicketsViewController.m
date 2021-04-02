//
//  TicketsViewController.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 08.03.2021.
//
#import "TicketsViewController.h"
#import "TicketTableViewCell.h"
#import "CoreDataHelper.h"
#import "NotificationCenter.h"
#import "DetailsTicketViewController.h"
#import "NSString+Localize.h"

#define TicketCellReuseIdentifier @"TicketCellIdentifier"

@interface TicketsViewController ()

@property (nonatomic, strong) NSArray *tickets;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *dateTextField;
@property (nonatomic) TypeFavorites typeFavorites;

@end

@implementation TicketsViewController {
    BOOL isFavorites;
    TicketTableViewCell *notificationCell;
}

#pragma mark - Initialisations

- (instancetype) initFavoriteTicketsController {
    self = [super init];
    if (self) {
        isFavorites = YES;
        [self configFavoriteTickets];
        self.tickets = [NSArray new];
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
    }
    return self;
}

- (instancetype) initWithTickets:(NSArray *)tickets {
    self = [super init];
    if (self)
    {   
        self.tickets = tickets;
        [self configTickets];
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
    }
    return self;
}

#pragma mark - configFavoriteTickets

- (void) configFavoriteTickets {
    [self configSegmentedControlForFavorites];
    [self configViewForFavorites];
    [self configTableViewForFavorites];
}

- (void) configSegmentedControlForFavorites {
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[[@"favorites_tickets" localize], [@"favorites_map_prices" localize]]];
    [self.segmentedControl addTarget:self action:@selector(changeTypeFavorites) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.tintColor = [UIColor blackColor];
    self.navigationItem.titleView = self.segmentedControl;
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (void) configViewForFavorites {
    self.title = [@"favorites_tab" localize];
}

- (void) configTableViewForFavorites {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - configTickets

- (void) configTickets {
    [self configViewForTickets];
    [self configTableViewForTickets];
    [self configDatePickerForTickets];
    [self configDateTextFieldForTickets];
    [self configToolBarForTickets];
}

- (void) configViewForTickets {
    self.title = [@"tickets_title" localize];
}

- (void) configTableViewForTickets {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void) configDatePickerForTickets {
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
}

- (void) configDateTextFieldForTickets {
    self.dateTextField = [[UITextField alloc] initWithFrame:self.view.bounds];
    self.dateTextField.hidden = YES;
    self.dateTextField.inputView = self.datePicker;
    [self.view addSubview:self.dateTextField];
}

- (void) configToolBarForTickets {
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTap:)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.dateTextField.inputAccessoryView = keyboardToolbar;
}

#pragma mark - Life cycle

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isFavorites) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        [self changeSource];
    }
}

#pragma mark - Private

- (void) changeTypeFavorites
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.typeFavorites = TypeFavoritesTicket;
            break;
        case 1:
            self.typeFavorites = TypeFavoritesMapPrice;
            break;
        default:
            break;
    }
    [self changeSource];
}

- (void) changeSource
{
    switch (self.typeFavorites) {
        case TypeFavoritesTicket:
            self.tickets = [[CoreDataHelper sharedInstance] favorites];
            break;
        case TypeFavoritesMapPrice:
            self.tickets = [[CoreDataHelper sharedInstance] favoritesMapPrice];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tickets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TicketCellReuseIdentifier forIndexPath:indexPath];
    if (isFavorites) {
        if (self.typeFavorites == TypeFavoritesTicket) {
            cell.favoriteTicket = [self.tickets objectAtIndex:indexPath.row];
        } else {
            cell.favoriteMapPrice = [self.tickets objectAtIndex:indexPath.row];
        }
    } else {
        cell.ticket = [self.tickets objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFavorites) {
        DetailsTicketViewController *detailsTicketViewController = [[DetailsTicketViewController alloc] init];
        switch (self.typeFavorites) {
            case TypeFavoritesTicket:
                detailsTicketViewController.favoriteTicket = [self.tickets objectAtIndex:indexPath.row];
                break;
            case TypeFavoritesMapPrice:
                detailsTicketViewController.favoriteMapPrice = [self.tickets objectAtIndex:indexPath.row];
                break;
            default:
                break;
        }
        [self.navigationController pushViewController:detailsTicketViewController animated:true];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[@"actions_with_tickets" localize] message:[@"actions_with_tickets_describe" localize] preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *favoriteAction;
        if ([[CoreDataHelper sharedInstance] isFavorite: [self.tickets objectAtIndex:indexPath.row]]) {
            favoriteAction = [UIAlertAction actionWithTitle:[@"remove_from_favorite" localize] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[CoreDataHelper sharedInstance] removeFromFavorite:[self.tickets objectAtIndex:indexPath.row]];
            }];
        } else {
            favoriteAction = [UIAlertAction actionWithTitle:[@"add_to_favorite" localize] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[CoreDataHelper sharedInstance] addToFavorite:[self.tickets objectAtIndex:indexPath.row]];
            }];
        }
        
        UIAlertAction *notificationAction = [UIAlertAction actionWithTitle:[@"remind_me" localize] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            if (![[CoreDataHelper sharedInstance] isFavorite: [self.tickets objectAtIndex:indexPath.row]]) {
                [[CoreDataHelper sharedInstance] addToFavorite:[self.tickets objectAtIndex:indexPath.row]];
            }
            self->notificationCell = [tableView cellForRowAtIndexPath:indexPath];
            self.datePicker.date = [NSDate date];
            self.datePicker.minimumDate = [NSDate date];
            [self.dateTextField becomeFirstResponder];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[@"close" localize] style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:favoriteAction];
        [alertController addAction:cancelAction];
        [alertController addAction:notificationAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Actions of doneButton

- (void)doneButtonDidTap:(UIBarButtonItem *)sender
{
    if (self.datePicker.date && notificationCell) {
        NSString *message = [NSString stringWithFormat:@"%@ - %@ за %@ %@", notificationCell.ticket.from, notificationCell.ticket.to, notificationCell.ticket.price, [@"reduction_rubles" localize]];
        
        NSURL *imageURL;
        if (notificationCell.airlineLogoView.image) {
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@.png", notificationCell.ticket.airline]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                UIImage *logo = notificationCell.airlineLogoView.image;
                NSData *pngData = UIImagePNGRepresentation(logo);
                [pngData writeToFile:path atomically:YES];
                
            }
            imageURL = [NSURL fileURLWithPath:path];
        }
        
        NSArray *values = [NSArray arrayWithObjects: notificationCell.ticket.price,
                           notificationCell.ticket.airline,
                           notificationCell.ticket.departure,
                           notificationCell.ticket.expires,
                           notificationCell.ticket.flightNumber,
                           notificationCell.ticket.returnDate,
                           notificationCell.ticket.from,
                           notificationCell.ticket.to,
                           nil];
        NSArray *keys = [NSArray arrayWithObjects: @"price",
                         @"airline",
                         @"departure",
                         @"expires",
                         @"flightNumber",
                         @"returnDate",
                         @"from",
                         @"to",
                         nil];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        Notification notification = NotificationMake([@"ticket_reminder" localize], message, self.datePicker.date, imageURL, userInfo);
        [[NotificationCenter sharedInstance] sendNotification:notification];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[@"success" localize] message:[NSString stringWithFormat:@"%@ - %@", [@"notification_will_be_sent" localize], self.datePicker.date] preferredStyle:(UIAlertControllerStyleAlert)];
        [NSString string];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[@"close" localize] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.datePicker.date = [NSDate date];
            self->notificationCell = nil;
            [self.view endEditing:YES];
            [self.dateTextField endEditing:YES];
        }];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
