# Lotus Wheel Design - The Wheel IS the Lotus!

## Concept
Instead of a traditional circular wheel with wedges, the player selector is now an **actual lotus flower** with 8 petals. Each petal represents a player count (1-8), creating a beautiful, cohesive design that matches the lotus symbolism throughout the app.

## Design Features

### Petal Shape
- **8 Curved Petals** - One for each player count
- **Organic Curves** - Petals extend slightly beyond the circle (15% extra radius)
- **Natural Flow** - Smooth bezier curves mimic real lotus petals
- **Inner Hollow** - Center area creates the characteristic lotus opening

### Color System

#### Unselected Petals
Alternating gradients for depth and dimension:

**Even Numbers (2, 4, 6, 8):**
- Top: Light blue `rgb(0.85, 0.92, 1.0)`
- Bottom: Lighter blue `rgb(0.92, 0.96, 1.0)`

**Odd Numbers (1, 3, 5, 7):**
- Top: Very light blue `rgb(0.90, 0.94, 1.0)`
- Bottom: Almost white `rgb(0.95, 0.97, 1.0)`

#### Selected Petal
- **Gradient**: Warm orange `Color.appAccent` fading to lighter orange
- **Glow**: White border (40% opacity, 2pt)
- **Effect**: Petal "blooms" and stands out

### Center Button
- **Shape**: Perfect circle in the lotus center
- **Size**: 38% of wheel diameter
- **Gradient**: Blue to orange (matching brand colors)
- **Content**: "START" with up arrow
- **Effects**: 
  - Inner white glow (radial gradient)
  - White ring border
  - Soft shadow beneath

### Background
- **Radial Gradient**: White center fading to light cyan
- **Shadow**: Soft blue shadow for depth
- **Effect**: Lotus appears to float

### Numbers
- **Position**: On each petal, outer edge
- **Size**: 36pt normal, 42pt when selected
- **Color**: Dark text on light petals, white on orange
- **Shadow**: Subtle shadow on selected for contrast
- **Rotation**: Numbers rotate with wheel

## Technical Implementation

### New Shape: `LotusWheelPetal`
```swift
LotusWheelPetal(
    petalIndex: count - 1,    // 0-7 for 8 petals
    totalPetals: 8,            // Total petals in lotus
    innerRadiusRatio: 0.38     // Inner circle size
)
```

**Features:**
- Calculates perfect petal angles (45° each)
- Creates curved outer edge using quad curves
- Maintains proper inner circle
- Seamless petal-to-petal transitions

### Gradient Application
```swift
LinearGradient(
    colors: petalGradient(for: count),
    startPoint: .top,
    endPoint: .bottom
)
```

### Interactive States
1. **Normal**: Subtle blue gradient
2. **Selected**: Vibrant orange gradient with glow
3. **Tap**: Animates rotation to center petal
4. **Drag**: Entire lotus rotates smoothly

## Visual Hierarchy

### Layers (Bottom to Top):
1. **Background glow** - Radial gradient
2. **Lotus petals** - 8 interactive segments
3. **Petal strokes** - Subtle borders
4. **Numbers** - Player count labels
5. **Center button** - START action
6. **Center glow** - Radial highlight

## Symbolism

The lotus is a perfect metaphor for Magic: The Gathering:
- **8 Petals** = 8 player count options
- **Center Opening** = The game begins
- **Blooming Effect** = Selection and growth
- **Rotating Motion** = Eternal cycle of games
- **Light Colors** = Purity and clarity

## User Experience

### Selection Flow
1. User sees lotus flower
2. Each petal clearly shows a number (1-8)
3. Tap a petal → it blooms (turns orange)
4. Wheel rotates to center the selected petal
5. Press START in the center to begin

### Visual Feedback
- **Tap**: Instant color change
- **Rotate**: Smooth animation (0.3s spring)
- **Selected**: Glowing orange petal
- **Ready**: Vibrant START button

## Advantages Over Traditional Wheel

### Before (Wedge Wheel):
- ❌ Generic circular segments
- ❌ Looked like a pie chart
- ❌ No connection to theme
- ❌ Straight edges

### After (Lotus Wheel):
- ✅ Beautiful organic shapes
- ✅ Looks like a blooming flower
- ✅ Perfect thematic match
- ✅ Curved, natural petals
- ✅ Unique and memorable

## Animation Possibilities

Current:
- Rotation when selecting
- Color transition on selection

Future Enhancements:
- Petals could "bloom" outward slightly when selected
- Subtle pulsing glow on center button
- Petal shimmer effect on load
- Particle effects when pressing START

## Accessibility

- **High Contrast**: Dark numbers on light petals
- **Clear Targets**: Each petal is easily tappable
- **Visual Feedback**: Selected petal is obviously different
- **Consistent Layout**: Always 8 petals in same position

## Code Quality

### Reusable Components
- `LotusWheelPetal` - Can be used elsewhere if needed
- `petalGradient()` - Consistent color system
- Separated logic from presentation

### Performance
- SwiftUI shapes render efficiently
- No complex animations (just rotation)
- Minimal overdraw

## Files Modified

1. **DesignSystem.swift**
   - Added `LotusWheelPetal` shape
   - Includes `pointOnCircle` math helper

2. **MainMenu.swift**
   - Replaced `WheelWedge` with `LotusWheelPetal`
   - Updated gradient system
   - Added `petalGradient()` function
   - Enhanced center button design

## Result

The wheel is now a **functional work of art** - a rotating lotus flower where each petal represents a player count. When you select a number, that petal "blooms" in orange, and the entire lotus rotates to center your selection. Press the glowing center button to begin your game.

It's not just a UI element - it's a beautiful, thematic experience that makes choosing player count feel special. 🪷✨
