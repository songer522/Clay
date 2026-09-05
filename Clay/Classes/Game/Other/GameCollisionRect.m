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

    // Level 3 mud / hay: modest pad like Level 2 sandpit/manure — both platforms.
    // Do not add large origin.y lifts here: haybaleRolling already had bbox.y lowered
    // 130→40 in objects.plist; stacking +36–40*MULTIPLIERY floated boxes above the path.
    if ([object isKindOfClass:[GameObject class]]) {
        GameObject *gameObject = (GameObject *)object;
        NSString *type = gameObject.objectType;

        if ([type isEqualToString:@"leafpile"]
            || [type isEqualToString:@"spilledDrink"]) {
            // Level 3 mud / Level 4 spilled drink: same low slow-pad layout.
            rect.origin.x -= 12.0f * MULTIPLIERX;
            rect.size.width += 24.0f * MULTIPLIERX;
            rect.origin.y -= 8.0f * MULTIPLIERY;
            rect.size.height += 22.0f * MULTIPLIERY;
        } else if ([type isEqualToString:@"discoHandbag"]) {
            // Phone keeps the jumpable 30×30 plist box. On iPad width/height*MULTIPLIER
            // outgrow the purse art, so shrink modestly while staying near the floor.
            if (IS_IPAD) {
                const CGFloat shrinkW = 18.0f;
                const CGFloat shrinkH = 22.0f;
                rect.origin.x += shrinkW * 0.5f;
                rect.origin.y += shrinkH * 0.2f;
                rect.size.width -= shrinkW;
                rect.size.height -= shrinkH;
            }
        } else if ([type isEqualToString:@"femaleBreakdancerRed"]
                   || [type isEqualToString:@"femaleBreakdancerBlue"]) {
            // plist bbox.y=50 is not multiplied at load while height is *MULTIPLIERY.
            // On iPad that leaves the box on the dancer's head instead of the rolling body.
            // After the Y fix, MULTIPLIER size is still a bit fat vs the rolling sprite.
            if (IS_IPAD) {
                rect.origin.y -= 70.0f; // 50 * (MULTIPLIERY - 1)
                const CGFloat shrinkW = 14.0f;
                const CGFloat shrinkH = 16.0f;
                rect.origin.x += shrinkW * 0.5f;
                rect.origin.y += shrinkH * 0.15f;
                rect.size.width -= shrinkW;
                rect.size.height -= shrinkH;
            }
        } else if ([type isEqualToString:@"haybaleSmall"]) {
            rect.origin.x -= 6.0f * MULTIPLIERX;
            rect.size.width += 12.0f * MULTIPLIERX;
            rect.origin.y -= 8.0f * MULTIPLIERY;
            rect.size.height += 18.0f * MULTIPLIERY;
        } else if ([type isEqualToString:@"haybaleRolling"]
                   || [gameObject getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_ROLLING_HAYBALE) {
            // Baseline Y from plist bbox.y=40. Phone pad is fine; on iPad
            // height*MULTIPLIERY (load) + pad*MULTIPLIERY floats the box above the bale.
            rect.origin.x -= 8.0f * MULTIPLIERX;
            rect.size.width += 16.0f * MULTIPLIERX;
            if (IS_IPAD) {
                rect.origin.y -= 64.0f;
                rect.size.height += 14.0f;
            } else {
                rect.origin.y -= 6.0f;
                rect.size.height += 14.0f;
            }
        } else if ([gameObject getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_FIREBALL_LANDED) {
            // Level 8 landed rock. Its plist box is 12x20 at bbox.y=0, so it sits at the
            // sprite origin and barely reaches the player's box, whose bottom is lifted to
            // his waist by player bbox.y=-10 - hence the walk-through.
            //
            // Lift it only. Do NOT also grow the height: matching fireDemon's 40-tall box
            // made the top 106 and forced a double jump. The rock is a low single-jump
            // obstacle like fireHedgehog (top 74), not a standing enemy.
            //   lift only        -> 66..86  (20 tall) — solid overlap, still single-jump
            //   +20 height       -> 66..106            — forces a double jump
            // If it ever needs tuning, move this lift; leave the height on the plist baseline.
            rect.origin.y += 10.0f * MULTIPLIERY;
        }
    }
    
    return rect;
}
