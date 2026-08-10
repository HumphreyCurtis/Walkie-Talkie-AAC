<p align="center">
  <img src="WalkieTalkieAAC/Assets.xcassets/AppIcon.appiconset/256.png" width="112" alt="Walkie Talkie AAC app icon">
</p>

<h1 align="center">Walkie Talkie AAC</h1>

<p align="center">
  Turn an iPhone into a sign. Wear it on a lanyard and show a message to the person you are talking to.
</p>

<p align="center">
  <img alt="Platform: iOS" src="https://img.shields.io/badge/platform-iOS-111111">
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-0078D4"></a>
</p>

Built from the CHI 2024 paper [_Breaking Badge_](https://dl.acm.org/doi/10.1145/3613904.3642327) (Curtis, Lau and Neate), co-designed with people with aphasia in workshops run with [Aphasia Re-Connect](https://aphasiareconnect.org).

Companion to [Watch Your Language AAC](https://github.com/HumphreyCurtis/Watch-Your-Language-AAC).

## What it does

| | |
|---|---|
| **Badges** | Messages shown outward in large type. Tap to speak. |
| **Symbol Speak** | Live speech recognition that shows a picture for the last word said. |
| **Photo to Speech** | Point the camera at something you cannot find the word for. |
| **Symbol Library** | Browse, search and favourite 500+ curated picture symbols. |
| **Search** | Pictures, maps, dictionary, Wikipedia — look something up mid-conversation. |
| **Aphasia Info** | Tappable sentences explaining aphasia, so you do not have to. |

Badges are rotated 180° by default — the phone hangs facing away from you, so "the right way up" is upside down from where you are standing.

## Writing badges with AI

Badges live in a plain JSON file, and the app can hand that file to whatever assistant you already use.

1. **Badges → Write badges with AI → Copy the prompt.** The prompt is self-contained: the schema, the colour names, verified SF Symbols, and your current badges.
2. Paste it into ChatGPT, Claude or Gemini and ask for what you need.
3. Paste the reply back and press **Check it**. You get a NEW / CHANGED / SAME list to approve before anything is saved.

Parsing is forgiving: prose and code fences around the JSON are ignored, invented SF Symbol names are replaced with a real one, colours outside the palette are mapped to the nearest, and a reply that would leave you with no badges is refused.

## Design

The visual language is public wayfinding — UK road signs and airport terminal boards. Flat saturated blocks, hard edges, no gradients.

- **DIN Alternate** for headings and the big outward words. DIN is the German road-sign standard; it reads as signage instantly.
- **Avenir Next** for body text. Avenir is Adrian Frutiger's, and Frutiger's other face was drawn for the signs at Charles de Gaulle, so the two sit in the same lineage.

Both ship with iOS, so there is nothing to bundle or license.

## Build the app

Open `Walkie Talkie AAC.xcodeproj` and run. iOS 17.0+, no dependencies, no package manager. The project uses a file-system-synchronized group, so new Swift files in `WalkieTalkieAAC/` are picked up automatically.

```
WalkieTalkieAAC/
  DesignSystem/   palette, typography, shared components
  Model/          Badge, BadgeStore, BadgeTransfer, Speaker, settings
  Features/       one file per screen
  Support/        speech recognition, Vision classifier, camera
```

## Privacy

Everything stays on the phone. No account, no server, no analytics, no ads, no third-party SDKs, no in-app purchases. Badges are stored in a local JSON file. Speech recognition and photo classification run on-device. The app makes no network requests of its own.

## Accessibility

Dynamic Type throughout, with rows that reflow rather than truncate at accessibility sizes. Reduce Motion stops UI animation; Increase Contrast and Reduce Transparency remove the chevron backdrop. Targets are large, for one-handed use.

## Acknowledgements

The people with aphasia and speech and language therapists who designed this, and [Aphasia Re-Connect](https://aphasiareconnect.org) (UK registered charity 1176125) who ran the workshops.

Symbols by [Mulberry Symbols](https://mulberrysymbols.org) © Garry Paxton / Steve Lee, CC BY-SA 4.0.

## License

MIT.