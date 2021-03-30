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

@interface TicketsViewController ()
@property (nonatomic, strong) NSArray *tickets;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic) TypeFavorites typeFavorites;
@end

@implementation TicketsViewController {
    BOOL isFavorites;
}

#pragma mark - Initialisation
- (instancetype)initFavoriteTicketsController {
    self = [super init];
    if (self) {
        isFavorites = YES;
        
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"По поиску", @"По карте"]];
        [self.segmentedControl addTarget:self action:@selector(changeSource) forControlEvents:UIControlEventValueChanged];
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
        if (self.typeFavorites == TypeFavoritesTicket) {
            self.tickets = [[CoreDataHelper sharedInstance] favorites];
        } else {
            self.tickets = [[CoreDataHelper sharedInstance] favoritesMapPrice];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Private

- (void)changeSource
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.typeFavorites = TypeFavoritesTicket;
            self.tickets = [[CoreDataHelper sharedInstance] favorites];
            break;
        case 1:
            self.typeFavorites = TypeFavoritesMapPrice;
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:favoriteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
