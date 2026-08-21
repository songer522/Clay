//
//  GameCollisionRect.m
//  Clay
//

#import "GameCollisionRect.h"
#import "GameObject.h"
#import "Sprite.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133f : 1.0f)
#define MULTIPLIERY (IS_IPAD ? 2.4f : 1.0f)

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
        } else if ([spriteName isEqualToString:@"Track_Sandpit_1.png"]
                   || [spriteName isEqualToString:@"Barn_Poop_1.png"]) {
            // Low slow-pads (sandpit / Level 2 manure): tiny legacy 15pt box misses
            // modern foot height — expand modestly (too tall forces double-jump).
            rect.origin.x -= 12.0f;
            rect.size.width += 24.0f;
            rect.origin.y -= 8.0f;
            rect.size.height += 22.0f;
        }
    }

    // Kicked hens use a tiny legacy 15x15 box that no longer matches the visual
    // sprite on modern phones, so cow-row chains look like hits but miss AABB.
    // Expand only while airborne/kicked; leave idle hen kick targeting alone.
    if ([object isKindOfClass:[GameObject class]]) {
        GameObject *gameObject = (GameObject *)object;
        CollisionBehavior behavior = [gameObject getCurrentCollisionBehavior];
        if (behavior == COLLISION_BEHAVIOR_HEN_KICKED) {
            rect.origin.x -= 18.0f;
            rect.origin.y -= 20.0f;
            rect.size.width += 36.0f;
            rect.size.height += 40.0f;
        }
    }

    // Level 3 mud / hay: raise low sprite-driven boxes into the path foot band
    // on both iPhone and iPad (do not gate behind !IS_IPAD).
    if ([object isKindOfClass:[GameObject class]]) {
        GameObject *gameObject = (GameObject *)object;
        NSString *type = gameObject.objectType;

        if ([type isEqualToString:@"leafpile"]) {
            // Mud slow-pad: raise into path foot band (both iPhone and iPad).
            rect.origin.x -= 12.0f * MULTIPLIERX;
            rect.size.width += 24.0f * MULTIPLIERX;
            rect.origin.y += 40.0f * MULTIPLIERY;
            rect.size.height += 22.0f * MULTIPLIERY;
        } else if ([type isEqualToString:@"haybaleSmall"]) {
            rect.origin.y += 40.0f * MULTIPLIERY;
            rect.size.height += 18.0f * MULTIPLIERY;
            rect.origin.x -= 6.0f * MULTIPLIERX;
            rect.size.width += 12.0f * MULTIPLIERX;
        } else if ([type isEqualToString:@"haybaleRolling"]
                   || [gameObject getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_ROLLING_HAYBALE) {
            rect.origin.y += 36.0f * MULTIPLIERY;
            rect.size.height += 20.0f * MULTIPLIERY;
            rect.origin.x -= 8.0f * MULTIPLIERX;
            rect.size.width += 16.0f * MULTIPLIERX;
        }
    }
    
    return rect;
}
