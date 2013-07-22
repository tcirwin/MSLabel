//
//  MSLabel.m
//  Miso
//
//  Created by Joshua Wu on 11/15/11.
//  Copyright (c) 2011 Miso. All rights reserved.
//

#import "MSLabel.h"
#import <CoreText/CoreText.h>

// small buffer to allow for characters like g,y etc 
static const int kAlignmentBuffer = 5;

@interface MSLabel ()

- (void)setup;

@property (nonatomic, assign) int drawX;

@end

@implementation MSLabel

@synthesize verticalAlignment = _verticalAlignment;
@synthesize _textHeight;
@synthesize drawX;

#pragma mark - Initilisation

- (id)initWithFrame:(CGRect)frame {
    
    
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        [self setup];
    }
    
    return self;
}

- (CGFloat)textOffsetForLine:(CTLineRef)line inRect:(CGRect)rect {
    CGFloat x;
    
    switch ([self textAlignment]) {
            
        case NSTextAlignmentLeft: {
            double offset = CTLineGetPenOffsetForFlush(line, 0, rect.size.width);
            x = offset;
            break;
        }
        case NSTextAlignmentCenter: {
            double offset = CTLineGetPenOffsetForFlush(line, 0.5, rect.size.width);
            x = offset;
            break;
        }
        case NSTextAlignmentRight: {
            double offset = CTLineGetPenOffsetForFlush(line, 2, rect.size.width);
            x = offset;
            break;
        }
        default:
            x = 0;
            break;
    }
    
    return x;
}

#pragma mark - Drawing

- (void)drawTextInRect:(CGRect)rect inContext:(CGContextRef)context {
    
    if (![self text]) {
        return;
    }
    
    //Setup the attributes dictionary with font and color
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)[self font], (id)kCTFontAttributeName,
                                [self textColor], kCTForegroundColorAttributeName,
                                nil];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                             initWithString:[self text]
                                             attributes:attributes];

    //Create a TypeSetter object with the attributed text created earlier on
    CTTypesetterRef typeSetter = CTTypesetterCreateWithAttributedString(CFBridgingRetain(attributedString));
    
    //Start drawing from the upper side of view (the context is flipped, so we need to grab the height to do so)
    CGFloat y = self.bounds.origin.y + self.bounds.size.height - self.font.ascender + kAlignmentBuffer;
    
    BOOL shouldDrawAlong = YES;
    int count = 0;
    CFIndex currentIndex = 0;
    
    _textHeight = 0;
    
    //Start drawing lines until we run out of text
    while (shouldDrawAlong) {
        
        //Get CoreText to suggest a proper place to place the line break
        CFIndex lineLength = CTTypesetterSuggestLineBreak(typeSetter,
                                                          currentIndex,
                                                          self.bounds.size.width);
        
        //Create a new line with from current index to line-break index
        CFRange lineRange = CFRangeMake(currentIndex, lineLength);
        CTLineRef line = CTTypesetterCreateLine(typeSetter, lineRange);
        
        //Create a new CTLine if we want to justify the text
        if ([self textAlignment] == NSTextAlignmentJustified) {
            
            CTLineRef justifiedLine = CTLineCreateJustifiedLine(line, 1.0, self.bounds.size.width);
            CFRelease(line); line = nil;
            
            line = justifiedLine;
        }
        
        CGFloat x = [self textOffsetForLine:line inRect:self.bounds];
        
        //Setup the line position
        CGContextSetTextPosition(context, x, y);
        CTLineDraw(line, context);
        
        //Check to see if our index didn't exceed the text, and if should limit to number of lines
        if ((currentIndex + lineLength >= [[self text] length]) &&
            !([self numberOfLines] && count < [self numberOfLines]-1) )    {
            shouldDrawAlong = NO;
            
        }
        
        count++;
        CFRelease(line);
        
        CGFloat minFontSizeChange = 1;
        y -= _lineHeight;
        
        currentIndex += lineLength;
        _textHeight  += _lineHeight;
    }
    
    CFRelease(typeSetter);
    
}
- (void)drawRect:(CGRect)rect {
    
    struct CGContext *context = UIGraphicsGetCurrentContext();
    
    //Grab the drawing context and flip it to prevent drawing upside-down
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSaveGState(context);
	
    [self drawTextInRect:rect inContext:context];
    
    CGContextRestoreGState(context);
}


#pragma mark - Properties

- (void)setLineHeight:(int)lineHeight
{
    if (_lineHeight == lineHeight) 
    { 
        return; 
    }
    
    _lineHeight = lineHeight;
    [self setNeedsDisplay];
}

#pragma mark - Private Methods

- (void)setup {
    _lineHeight = 12;
    self.minimumFontSize = 12;
    _verticalAlignment = MSLabelVerticalAlignmentMiddle;
}

@end
