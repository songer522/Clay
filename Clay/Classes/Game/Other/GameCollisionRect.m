//
//  GameCollisionRect.m
//  Clay
//

#import "GameCollisionRect.h"
#import "GameObject.h"
#import "Sprite.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

CGRect GameCollisionRectForObject(id<Collidable> object)
{
    // Most legacy obstacles are visually placed with sprite offsets, so collisions
    // need to follow the rendered sprite position instead of the raw world origin.
    CGPoint position = [object getCCSprite].position;
    CGRect boundingBox = [object getBoundingBox];
    CGRect rect = CGRectMake(position.x - boundingBox.origin.x,
                             position.y - boundingBox.origin.y,
                             boundingBox.size.width,
                             boundingBox.size.height);
    
    // Some very low legacy phone-era obstacles need a little extra overlap on
    // modern phones so the player's feet still enter the intended effect area.
    if (!IS_IPAD && [object isKindOfClass:[GameObject class]]) {
        GameObject *gameObject = (GameObject *)object;
        NSString *spriteName = [[gameObject getSprite] name];

        if (gameObject.isHurdle && boundingBox.size.height <= 15.0f && boundingBox.size.width <= 15.0f) {
            rect.origin.x -= 36.0f;
            rect.size.width += 42.0f;
            rect.size.height += 10.0f;
        } else if ([spriteName isEqualToString:@"Track_Sandpit_1.png"]) {
            rect.origin.x -= 18.0f;
            rect.size.width += 36.0f;
            rect.origin.y -= 10.0f;
            rect.size.height += 18.0f;
        }
    }
    
    return rect;
}
