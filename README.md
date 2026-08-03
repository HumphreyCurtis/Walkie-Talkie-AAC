# Walkie Talkie AAC

Turn an iPhone into a sign.

Wear it on a lanyard facing outward and show a message to the person you are
talking to — one word at a time, big enough to read at a glance. It is a
safety net for when talking breaks down, not a replacement for your voice.

Built from the CHI 2024 paper [_Breaking Badge: Augmenting Communication with
Wearable AAC Smartbadges and Displays_](https://dl.acm.org/doi/10.1145/3613904.3642327)
(Curtis, Lau and Neate), and co-designed with people with aphasia in workshops
run with [Aphasia Re-Connect](https://aphasiareconnect.org).

Companion to [Watch Your Language AAC](https://github.com/HumphreyCurtis/Watch-Your-Language-AAC).

## What it does

| | |
|---|---|
| **Badges** | Your messages, shown outward one word at a time. Tap to speak. |
| **Attention** | A display that escalates green → amber → red over fifteen seconds, for when you need to be noticed. |
| **Symbol Speak** | Live speech recognition, showing the picture for the last word said. |
| **Photo to Speech** | Point the camera at something you cannot find the word for. |
| **Slow Sunflower** | A calm display to go alongside a Hidden Disabilities Sunflower lanyard. |
| **Search** | Pictures, maps, dictionary, Wikipedia — look something up mid-conversation. |
| **Aphasia Info** | Tappable sentences explaining aphasia, so you do not have to. |

Badges are rotated 180° by default. The phone hangs facing away from you, so
"the right way up" is upside down from where you are standing.

## Writing badges with AI

Badges live in a plain JSON file, and the app can hand that file to whatever
assistant you already use.

1. **Badges → Write badges with AI → Copy the prompt.** The prompt is
   self-contained: the schema, the eight colour names, a set of verified SF
   Symbols, and your current badges so the assistant can edit as well as add.
2. Paste it into ChatGPT, Claude or Gemini and ask for what you need —
   "badges for a hospital appointment", "make these shorter".
3. Paste the reply back and press **Check it**. You get a NEW / CHANGED / SAME
   list to approve before anything is saved.

Parsing is forgiving on purpose. Prose and code fences around the JSON are
ignored, invented SF Symbol names are replaced with a real one, colours outside
the palette are mapped to the nearest, and an entry with no label gets one from
its message. A reply that would leave you with no badges is refused.

**Badges → Edit as JSON** exposes the same file as editable text, for setting a
phone up in one go or moving a vocabulary between devices.

## Design

The visual language is public wayfinding — UK road signs and airport terminal
boards. Flat saturated blocks, hard edges, no gradients.

- **DIN Alternate** for headings and the big outward words. DIN is the German
  road-sign standard; it reads as signage instantly.
- **Avenir Next** for body text. Avenir is Adrian Frutiger's, and Frutiger's
  other face was drawn for the signs at Charles de Gaulle, so the two sit in
  the same lineage.

Both ship with iOS, so there is nothing to bundle or license.

Colours are stored as hex rather than as SwiftUI `Color`s so that contrast
against them can be computed (`SignColor.contrast(against:)`). Controls on a
full-bleed badge derive their colours from whatever is behind them, which is
why a blue button never disappears on a blue badge.

## Building

Open `Walkie Talkie AAC.xcodeproj` and run. iOS 17.0+, no dependencies, no
package manager. The project uses a file-system-synchronized group, so new
Swift files in `WalkieTalkieAAC/` are picked up automatically.

```
WalkieTalkieAAC/
  DesignSystem/   palette, typography, shared components
  Model/          Badge, BadgeStore, BadgeTransfer, Speaker, settings
  Features/       one file per screen
  Support/        speech recognition, CoreML classifier, camera
```

## Privacy

Everything stays on the phone. No account, no server, no analytics, no ads, no
third-party SDKs, no in-app purchases.

Badges are stored in `Badges.json` in the app's own Documents directory. Speech
recognition and photo classification run on-device. The app makes no network
requests of its own; Search and the links on the About page open Safari, where
those sites' own policies apply. The AI import goes through your clipboard —
you choose which assistant sees it, and you can read the prompt first.

## Accessibility

Dynamic Type throughout, with rows that reflow rather than truncate at
accessibility sizes. Reduce Motion stops the sunflower drift; Increase Contrast
and Reduce Transparency remove the chevron backdrop. Contrast is computed
rather than assumed. Targets are large, for one-handed use.

The hidden-disability button is **off** by default. Telling a carriage full of
strangers about a disability is the wearer's decision to make deliberately.

## Not a medical device

This app is not a medical device and not an emergency service. It is an aid for
everyday conversation.

## Acknowledgements

The people with aphasia and speech and language therapists who designed this,
and Aphasia Re-Connect (UK registered charity 1176125) who ran the workshops.

## Licence

MIT.
