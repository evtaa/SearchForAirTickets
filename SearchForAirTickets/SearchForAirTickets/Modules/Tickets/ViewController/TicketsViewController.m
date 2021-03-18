//
//  TicketsViewController.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 08.03.2021.
//
#define TicketCellReuseIdentifier @"TicketCellIdentifier"

#import "TicketsViewController.h"
#import "TicketTableViewCell.h"

@interface TicketsViewController ()
@property (nonatomic, strong) NSArray *tickets;
@end

@implementation TicketsViewController

#pragma mark - Initialisation
- (instancetype)initWithTickets:(NSArray *)tickets {
    self = [super init];
    if (self)
    {
        _tickets = tickets;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tickets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TicketCellReuseIdentifier forIndexPath:indexPath];
    cell.ticket = [self.tickets objectAtIndex:indexPath.row];
    //[cell setTicket:[self.tickets objectAtIndex:indexPath.row]];
   
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0;
}

@end
