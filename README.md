# 🟥 Flutter C-Shape Animated Box App

This Flutter app allows users to input a number between **5 and 25** to dynamically generate square boxes arranged in a **‘C’ shaped layout**. It includes **color animations**, **tap interactions**, and a **reverse animation** sequence once all boxes are turned green.

---

## 🚀 Features

- 📥 **Dynamic Input**: User provides a number (5–25) to generate that many boxes.
- 🧱 **C-Shape Layout**: Boxes are arranged in a way that mimics the shape of the letter ‘C’.
- 🖐️ **Tap Interaction**: Tapping a box toggles it from red to green, tracking the order.
- ⏱ **Reverse Animation**:
  - Automatically starts once all boxes are green.
  - Turns boxes back to red in **reverse tap order**, one per second.
- 🎨 **Smooth Animations**:
  - Color transitions between red and green are animated using `AnimationController` and `ColorTween`.

---

## 🖼️ Layout Behavior – How the 'C' Shape is Formed

Given `N` boxes:
- The boxes are split roughly into **3 parts**:
  1. **Top Row**: `ceil(N / 3)` boxes, laid left to right.
  2. **Middle Vertical Line**: `N - 2 * ceil(N / 3)` boxes, laid top to bottom as one box per row.
  3. **Bottom Row**: Again `ceil(N / 3)` boxes, laid left to right.

This forms a visual structure like:

### For N = 9:

🟥 🟥 🟥
🟥
🟥
🟥 🟥 🟥


---

## ⚙️ How Animation Works

### 📦 Initialization

Each box is initialized with:

- Color: `Colors.red`
- Animation: A `ColorTween` from red to green using a dedicated `AnimationController`.

### 👆 On Tap

When a box is tapped:

- If it's still red and `isAnimating` is false:
  - The color transitions to green using the animation controller.
  - Its index is added to a list called `greenOrder` to record the tap sequence.

### 🔁 Reverse Animation

Once all `N` boxes are green:

- The `isAnimating` flag is set to `true`.
- A reverse timer starts:
  - Waits **1 second** between steps.
  - Reverts each box’s animation from green back to red in the **reverse order** of taps.
- After all boxes return to red:
  - Interaction becomes enabled again for a new round.

---

## 📄 App Structure





