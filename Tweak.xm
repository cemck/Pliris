@interface CatalogViewController : UIViewController
- (void)plirisButtonTapped:(id)sender event:(id)event;
- (NSString *)tableView:(UITableView *)tableView getTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)_textFieldEditingChanged;
@end

@interface CompletionListTableViewController : UITableViewController
@end

@interface UnifiedField : UITextField
- (void)_textDidChangeFromTyping;
@end

%hook CatalogViewController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell* cell = %orig;
    if ([cell isKindOfClass:%c(SearchSuggestionTableViewCell)]) {
        UIImage *arrowImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Pliris.bundle/arrow.png"];
        UIButton *plirisButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [plirisButton setFrame:CGRectMake(0, 0, 20, 20)];
        [plirisButton setImage:arrowImage forState:UIControlStateNormal];
        [plirisButton addTarget:self action:@selector(plirisButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = plirisButton;
    }
    return cell;
}

%new
- (void)plirisButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CompletionListTableViewController *c = MSHookIvar<CompletionListTableViewController *>(self, "_completionsViewController");

    CGPoint currentTouchPosition = [touch locationInView:(UITableView *)c.view];
    NSIndexPath *indexPath = [(UITableView *)c.view indexPathForRowAtPoint: currentTouchPosition];

    if (indexPath != nil){
        NSString *text = [self tableView: (UITableView *)c.view getTextForRowAtIndexPath: indexPath];
        UnifiedField *u = MSHookIvar<UnifiedField *>(self, "_textField");
        [u setText:text];
        [u _textDidChangeFromTyping];
        [self _textFieldEditingChanged];
    }
}

%new
- (NSString *)tableView:(UITableView *)tableView getTextForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *text = cell.textLabel.text;
    return text;
}
%end
