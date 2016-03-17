####一、树形列表实现效果：

`这个是为朋友实现的；不多少说，直接看效果吧。`

<img src="https://github.com/debugly/TreeList/blob/master/treeList.gif" width="747" height="1113">


####二、侧滑删除（兼容老版本）实现：

`之前使用我使用了 SWTableViewCell 来做侧滑删除，可是使用 Instrument 检测发现，他有性能问题；我的列表本可以更加流畅，但是每次滑动 cell ，都需要更新侧滑按钮，即使没有显示出来！SW 创建了按钮之后还要重新布局，这些都是性能上的消耗...`

`我现在做了一套逻辑，完全使用系统的懒加载形式，仅当侧滑时才配置侧滑菜单按钮,点击按钮的事件和iOS8系统原生的一样，采用 block 回调方式...`

`与 SW 相比，使用方式也不复杂，并且性能上没有问题...`

使用方法：

```objc
    - (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        QLTableViewRowAction *action1 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleDefault title:@"1自动删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
            //handle your click event
        }];

        QLTableViewRowAction *action2 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleDefault title:@"2自删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
            //handle your click event
        }];

        QLTableViewRowAction *action3 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"3删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
            //handle your click event
        }];

        QLTableViewRowAction *action4 = [QLTableViewRowAction rowActionWithStyle:QLTableViewRowActionStyleNormal title:@"4不删除" handler:^(QLTableViewRowAction *action, NSIndexPath *indexPath) {
            //handle your click event
        }];

        NSArray *bgColors = @[[UIColor colorWithRed:255.0f/255.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0],
        [UIColor colorWithRed:255.0f/255.0f green:156.0f/255.0f blue:3.0f/255.0f alpha:1.0],
        [UIColor colorWithRed:255.0f/255.0f green:128.0f/255.0f blue:1.0f/255.0f alpha:1.0]];

        //configure bg color
        action2.backgroundColor = bgColors[1];
        action3.backgroundColor = bgColors[1];
        action4.backgroundColor = bgColors[2];

        if (indexPath.row == 0) {
            return @[action1];
        }else if (indexPath.row == 1){
            return @[action1,action2];
        }else if (indexPath.row == 2){
            return @[action1,action2,action3];
        }

        return @[action1,action2,action3,action4];
    }

```

效果：

<img src="https://github.com/debugly/TreeList/blob/master/treeListEdit.gif" width="747" height="1113">