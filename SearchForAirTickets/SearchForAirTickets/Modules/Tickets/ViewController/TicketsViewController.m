//
//  TicketsViewController.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 08.03.2021.
//
#define TicketCellReuseIdentifier @"TicketCellIdentifier"

#import "TicketsViewController.h"
#import "TicketTableViewCell.h"
#import "CoreDataHelper.h"
#import "NotificationCenter.h"

@interface TicketsViewController ()
@property (nonatomic, strong) NSArray *tickets;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic) TypeFavorites typeFavorites;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *dateTextField;
@end

@implementation TicketsViewController {
    BOOL isFavorites;
    TicketTableViewCell *notificationCell;
}

#pragma mark - Initialisation
- (instancetype)initFavoriteTicketsController {
    self = [super init];
    if (self) {
        isFavorites = YES;
        
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"По поиску", @"По карте"]];
        [self.segmentedControl addTarget:self action:@selector(changeTypeFavorites) forControlEvents:UIControlEventValueChanged];
        self.segmentedControl.tintColor = [UIColor blackColor];
        self.navigationItem.titleView = self.segmentedControl;
        self.segmentedControl.selectedSegmentIndex = 0;
        
        self.tickets = [NSArray new];
        self.title = @"Избранное";
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
    }
    return self;
}

- (instancetype)initWithTickets:(NSArray *)tickets {
    self = [super init];
    if (self)
    {
        self.tickets = tickets;
        self.title = @"Билеты";
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
        
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        //self.datePicker.minimumDate = [NSDate date];
        
        self.dateTextField = [[UITextField alloc] initWithFrame:self.view.bounds];
        self.dateTextField.hidden = YES;
        self.dateTextField.inputView = self.datePicker;
        
        UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
        [keyboardToolbar sizeToFit];
        UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTap:)];
        keyboardToolbar.items = @[flexBarButton, doneBarButton];
        
        self.dateTextField.inputAccessoryView = keyboardToolbar;
        [self.view addSubview:self.dateTextField];
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFavorites) return;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Действия с билетом" message:@"Что необходимо сделать с выбранным билетом?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *favoriteAction;
    if ([[CoreDataHelper sharedInstance] isFavorite: [self.tickets objectAtIndex:indexPath.row]]) {
        favoriteAction = [UIAlertAction actionWithTitle:@"Удалить из избранного" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] removeFromFavorite:[self.tickets objectAtIndex:indexPath.row]];
        }];
    } else {
        favoriteAction = [UIAlertAction actionWithTitle:@"Добавить в избранное" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] addToFavorite:[self.tickets objectAtIndex:indexPath.row]];
        }];
    }
    
    UIAlertAction *notificationAction = [UIAlertAction actionWithTitle:@"Напомнить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        self->notificationCell = [tableView cellForRowAtIndexPath:indexPath];
        self.datePicker.date = [NSDate date];
        self.datePicker.minimumDate = [NSDate date];
        [self.dateTextField becomeFirstResponder];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:favoriteAction];
    [alertController addAction:cancelAction];
    [alertController addAction:notificationAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Actions For

- (void)doneButtonDidTap:(UIBarButtonItem *)sender
{
    if (self.datePicker.date && notificationCell) {
        NSString *message = [NSString stringWithFormat:@"%@ - %@ за %@ руб.", notificationCell.ticket.from, notificationCell.ticket.to, notificationCell.ticket.price];
        
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
        
        Notification notification = NotificationMake(@"Напоминание о билете", message, self.datePicker.date, imageURL);
        [[NotificationCenter sharedInstance] sendNotification:notification];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Успешно" message:[NSString stringWithFormat:@"Уведомление будет отправлено - %@", self.datePicker.date] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
        self.datePicker.date = [NSDate date];
        notificationCell = nil;
        [self.view endEditing:YES];
        [self.dateTextField endEditing:YES];
}


@end
