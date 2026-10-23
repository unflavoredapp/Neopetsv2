# PetPals

A native iPhone virtual-pet game prototype built with SwiftUI. Adopt a pet, pick its species and color, and manage a small roster, all saved on your device.

> **Status:** early prototype. It has not been compiled or run by its author yet, so expect to fix a few build errors on first open.

## Features

- **Dashboard** with pet info, a health bar, four stat badges, quick-action icons, a pet roster and collection tiles
- **Create-a-Pet** flow with a species grid, four colors, a name field and a gender picker, with a live preview
- **My Pets** and **Profile** screens
- **Local saves** for your roster and selected pet (UserDefaults, no account or network)
- **Original creatures drawn entirely in code** (12 species x 4 colors), so there are no image assets to license

## Species

Glimmoo, Bunnoo, Fluffet, Snorbit, Wingle, Toadle, Tuftail, Pebbo, Squeakle, Dribble, Mooble and Starbit. Each is a variation on one body plan with different ears, extras and proportions. See `PetPals/CreatureArt.swift`.

## Requirements

- macOS with **Xcode 16** or newer
- iOS **16.0+** deployment target (iPhone and iPad)

## Build and run

1. Clone the repo and open `PetPals.xcodeproj` in Xcode.
2. Select the **PetPals** target, then **Signing & Capabilities**.
3. Choose your Apple Developer Team and change the bundle identifier from `com.example.PetPals` to one that is unique to you.
4. Pick an iPhone simulator and press **Run**.

To put it on a device or share a build, select **Any iOS Device (arm64)**, choose **Product > Archive**, then use **Distribute App** in Organizer. This needs a signing certificate from your Apple Developer account.

## Automated unsigned IPA (GitHub Actions)

`.github/workflows/build-ipa.yml` builds the app on a macOS runner with code signing turned off and uploads `PetPals-unsigned.ipa` as a workflow artifact. It runs on every push to `main`, on pull requests, and on demand from the **Actions** tab (**Run workflow**).

- Compiled objects and the module cache are cached between runs, so repeat builds are faster.
- Download the IPA from the finished run's **Artifacts** section (kept for 14 days).
- The IPA is unsigned. To install it you need to re-sign it, for example with a tool like Sideloadly or AltStore, or with your own certificate.

## Project layout

```
.github/workflows/     CI workflow that builds the unsigned IPA
PetPals/
  PetPalsApp.swift     App entry, models, game state, screens
  CreatureArt.swift    Species, colors and the code-drawn creature renderer
  Assets.xcassets/     App icon
PetPals.xcodeproj/     Includes a shared scheme so CI can build it
```

## Adding a species

Add an entry to `SpeciesInfo.all` in `CreatureArt.swift` with a name, an ear style, an extra and body proportions. It appears in Create-a-Pet automatically.

## Roadmap ideas

- Pet care: hunger, mood and energy that change over time
- Mini-games that pay out in Pebbles
- A shop and inventory
- Daily rewards
- A SpriteKit scene for the pet's room and mini-games

## Not affiliated

PetPals is an independent project. It is not affiliated with, endorsed by, or connected to Neopets or any other virtual-pet franchise, and it does not use their art, names or services. All creatures, names and artwork here are original.

## License

Code and artwork are released under the [MIT License](LICENSE).
