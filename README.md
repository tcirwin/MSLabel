MSLabel is a custom UILabel that allows you to specify LineHeight and Anchor
point, but it inherits from UILabel so you can use it in conjunction with the
storyboard.

 - Author: Joshua Wu
 - CoreText Code: Michal Tuszynski and Martin Hwasser

How To Use
----------
1. Add to your Podfile, then run `pod install`.
1. Insert a UILabel into your storyboard or xib file in Xcode.
2. Select the new UILabel, then open the "Identity Inspector" tab on the right.
3. Change the "Custom Class" to `MSLabel`.
4. Connect the label to your view or cell as an outlet. Make sure the "Type" is
"MSLabel".

Usage
-----
It supports most UILabel properties including text alignment, font, colors...etc.

line height specifies the number of pixels between draw points of each line.
anchorToBottom specifies whether the text grows from the top of the frame or the bottom.

eg.
```objective-c
MSLabel *titleLabel = [[[MSLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)] autorelease];
titleLabel.lineHeight = 13;
titleLabel.anchorToBottom = YES;
titleLabel.numberOfLines = 2;
titleLabel.text = @"Some really really long text that goes to the second line";
[self.view addSubview:titleLabel];
```

Unsupported
-----------
- \n line breaks are ignored
- Does not support UILineBreakModes. By default MSLabel truncates the last line with ...
