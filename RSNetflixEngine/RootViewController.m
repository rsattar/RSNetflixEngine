//
//  RootViewController.m
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 Rizwan Sattar. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize netflixAPIContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    
    netflixUserAuthorizationInProgress = NO;
    
    // Initialize our netflix engine
    
    /*
    // Initialize RSNetflixEngine
    netflix = [[RSNetflixEngine alloc] initWithConsumerKey:RS_NETFLIX_ENGINE_API_KEY sharedSecret:RS_NETFLIX_ENGINE_SHARED_SECRET applicationName:RS_NETFLIX_ENGINE_APPLICATION_NAME];
    // Make a test call
    //[netflix callAPIMethod:@"catalog/titles/autocomplete" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[netflix consumerKey],@"oauth_consumer_key",@"frances%20mc",@"term", nil] isSigned:NO];
    
    [netflix callAPIMethod:@"catalog/people" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"max_results",@"frances mc",@"term", nil] isSigned:YES];
    */
    
    /*
    RSNetflixAPIRequest *request = [[RSNetflixAPIRequest alloc] initWithAPIContext:netflixAPIContext];
    request.delegate = self;
    [request callAPIMethod:RSNetflixMethodSearchPeople arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"max_results",@"frances mc",@"term", nil] isSigned:YES];
    */
    
    
    netflix = [[RSNetflixEngine alloc] initWithAPIContext:netflixAPIContext];
    
    
    //[netflixEngine searchForTitlesMatchingTerm:@"Star"];
    //oAuthRequestId = [[netflix requestOAuthToken] retain];
    /*
    [netflix requestOAuthTokenWithSuccessBlock:^(NSString *loginUrl) {
        
        NSLog(@"OMG Received an oauth response! Login url is: %@",loginUrl);
    }
                                    errorBlock:^(NSError *error) {
                                        NSLog(@"OMG received an error for requesting oauth token via block");
                                    }];
    */
    
    // Testing blocks out with API Requests
    /*
    RSNetflixAPIRequest *request = [[RSNetflixAPIRequest alloc] initWithAPIContext:netflixAPIContext];
    [request callAPIMethod:RSNetflixMethodSearchPeople 
                 arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"max_results",@"frances mc",@"term", nil] 
                  isSigned:YES
          withSuccessBlock:^(NSDictionary *response) {
              NSLog(@"Got response back as block! %@",response);
          } 
                errorBlock:^(NSError *error) {
                    NSLog(@"Got error back as block! %@", error);
                }];
     */
    
    netflix.delegate = self;
    
    // Build a cheap and simple model to build our table view UI with
    buttonOrder = [[NSMutableArray alloc] initWithObjects:
                   @"titleSearch", 
                   nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [buttonOrder count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 1;
    } else if(section == 1) {
        return [buttonOrder count];
    }
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        // This is our Authorize Netflix, or Clear User Credentials button
        if([netflix.apiContext.userId length] > 0) {
            cell.textLabel.text = @"Clear User Credentials";
        } else if(netflixUserAuthorizationInProgress) {
            cell.textLabel.text = @"Authorizing...";
        } else {
            cell.textLabel.text = @"Authorize Netflix";
        }
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    } else if(indexPath.section == 1) {
        
        NSString *buttonId = [buttonOrder objectAtIndex:indexPath.row];
        if([buttonId isEqualToString:@"titleSearch"]) {
            cell.textLabel.text = @"Search Titles for 'Star'";
        }
    }

    // Configure the cell.
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0) {
        
        if([netflix.apiContext.userId length] > 0) {
            return @"Signed in; User API available";
        } else {
            return @"Authorizing Netflix greatly increases API request quota.";
        }
    } else if (section == 1) {
        return @"These currently don't show the response, so just *assume* they worked :)";
    }
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
    if(indexPath.section == 0 && indexPath.row == 0) {
        // Sign In/Out toggle
        if([netflix.apiContext.userId length] > 0) {
            // need to sign out
            netflix.apiContext.oAuthAccessToken = nil;
            netflix.apiContext.oAuthAccessTokenSecret = nil;
            netflix.apiContext.userId = nil;
        } else {
            netflixUserAuthorizationInProgress = YES;
            [netflix requestOAuthTokenWithSuccessBlock:^(NSString *loginUrlString) {
                [self.tableView reloadData];
            } errorBlock:^(NSError *error) {
                netflixUserAuthorizationInProgress = NO;
                NSLog(@"Encountered error requesting OAuth token");
                [self.tableView reloadData];
            }];
        }
        [self.tableView reloadData];
    } else if(indexPath.section == 1) {
        
        NSString *buttonId = [buttonOrder objectAtIndex:indexPath.row];
        if([buttonId isEqualToString:@"titleSearch"]) {
            
            [netflix searchForTitlesMatchingTerm:@"Star" withMaxResults:5 andPageOffset:-1 
                                withSuccessBlock:^(NSDictionary *response) {
            
                                } errorBlock:^(NSError *error) {
            
                                }];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [buttonOrder release];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [netflix release];
}

- (void)dealloc
{
    [loginViewController release];
    [netflixAPIContext release];
    [super dealloc];
}

#pragma mark -
#pragma mark Engine Request delegate

- (void)netflixEngine:(RSNetflixEngine *)engine requestSucceeded:(NSString *)identifier withResponse:(NSDictionary *)response
{
    NSLog(@"RSNetflixEngineDelegate didComplete for request id %@ with response \n%@", identifier, response);
}

- (void)netflixEngine:(RSNetflixEngine *)engine requestFailed:(NSString *)identifier withError:(NSError *)error
{
    NSLog(@"RSNetflixEngineDelegate didFailWithError");
}

- (void)netflixEngine:(RSNetflixEngine *)engine oAuthTokenRequestSucceededWithLoginUrlString:(NSString *)loginUrl forRequestId:(NSString *)requestId
{
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:loginUrl]];
    loginViewController = [[RSUserLoginViewController alloc] initWithNibName:@"RSUserLoginViewController" bundle:[NSBundle mainBundle]];
    loginViewController.delegate = self;
    loginViewController.loginUrl = loginUrl;
    loginViewController.callBackUrl = netflixAPIContext.userLoginCallbackUrl;
    
    [self.navigationController presentModalViewController:loginViewController animated:YES];
}

- (void)netflixEngine:(RSNetflixEngine *)engine oAuthTokenAccessSucceededForRequestId:(NSString *)requestId
{
    // We got access!
    
    netflixUserAuthorizationInProgress = NO;
    [self.tableView reloadData];
    
    // Make a access-only request, like users/user_id
    [netflix retrieveUserInformationForUserId:netflix.apiContext.userId];
    
}

#pragma - RSUserLoginViewControllerDelegate

- (void)userLoginViewControllerSucceeded:(RSUserLoginViewController *)viewController withResponse:(NSDictionary *)loginResponse {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [loginViewController autorelease];
    }];
    
    //NSString *oAuthAuthorizedToken = [loginResponse objectForKey:@"oauth_token"];
    // From now on, all signed requests, will actually be made as protected requests, 
    // which has a higher quota, and can do more things
    //netflix.apiContext.oAuthAuthorizedToken = oAuthAuthorizedToken;
    
    // Now make the access_token call, so that we have the last peice of the puzzle, the authorized token and SECRET
    [netflix accessOAuthToken];
    
}
- (void)userLoginViewControllerCancelled:(RSUserLoginViewController *)viewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [loginViewController autorelease];
    }];
}

@end
