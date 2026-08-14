# App Review Information — Notes

Paste the section below into **App Store Connect → App Review Information →
Notes** for every submission. It answers the seven questions Apple asked under
Guideline 2.1.

The screen recording referred to in item 1 is attached to the submission
separately; it is captured on the same iPhone 17 Pro listed in item 2.

---

## Reply to paste

**What this app is**

Walkie Talkie AAC is a free Augmentative and Alternative Communication (AAC)
aid. It turns an iPhone worn on a lanyard, arm strap or belt clip into an
outward-facing sign, so the wearer can show a short message to the person they
are speaking to, and optionally have the phone speak it aloud.

It is designed for people with aphasia — a communication disability, usually
acquired after a stroke, that can make speaking, reading or writing difficult
without affecting intelligence. It is also useful to anyone who is temporarily
or permanently non-speaking.

The app was co-designed with people with aphasia in participatory workshops run
with Aphasia Re-Connect (UK registered charity 1176125) and is based on
peer-reviewed research published at ACM CHI 2024 (DOI 10.1145/3613904.3642327),
of which the developer is the first author.

**The problem it solves.** In a shop, a pharmacy or on public transport, a
person with aphasia may be unable to produce a sentence in the moment, and the
stranger they are talking to has no idea why. This app lets them show the
sentence instead of saying it, and explains their disability on their behalf so
they do not have to.

---

**1. Screen recording**

Attached, captured on a physical iPhone 17 Pro running iOS 26.5.2.

There is no account registration, login or account deletion flow, no paid
content, subscription or purchase flow, and no user-generated content shared
between users, so none of those appear. Prompts requesting access to device
capabilities do appear, and are shown in the recording.

The recording covers, in order:

1. Launching the app. The main menu appears immediately — no onboarding and no
   sign-in.
2. Opening **Badges** and selecting a badge. It fills the screen, rotated 180°
   so it faces the person being spoken to. Tapping the screen speaks it aloud.
3. Changing that badge's background colour, and adding a background photo. The
   system **camera** permission prompt appears at this point.
4. Creating a new badge: typing a message and saving it.
5. **Symbol Speak**, which listens and shows the picture symbol for each word
   spoken. The **microphone** and **speech recognition** permission prompts
   appear at this point.
6. **Photo to Speech**, which suggests words for a photographed object using an
   on-device model.
7. **Search**, which hands a query to Safari and leaves the app.
8. **Settings** (voice, speed, orientation) and **About** (the research behind
   the app, and an explanation of aphasia).

**2. Devices and operating systems tested**

Built with Xcode 26.6 (17F113) against the iOS 26.5 SDK.

Verified on:

| Device | OS | |
|---|---|---|
| iPhone 17 Pro | iOS 26.5.2 | Physical device |
| iPhone 15 | iOS 17.0.1 (21A342) | Simulator |
| iPad (10th generation) | iOS 17.0.1 (21A342) | Simulator |

Testing covers both ends of the supported range: the current hardware and OS on
a physical device, and iOS 17.0 — the app's minimum deployment target — so the
oldest supported configuration is verified rather than only the newest.

The app supports iPhone and iPad running **iOS 17.0 or later**:

- **iPhone** — XR, XS, XS Max and every model since, including SE (2nd and 3rd
  generation).
- **iPad** — iPad (6th generation and later), iPad Air (3rd generation and
  later), iPad mini (5th generation and later), iPad Pro 10.5-inch, iPad Pro
  11-inch (all generations), iPad Pro 12.9-inch (2nd generation and later).

Portrait and landscape are both supported, along with Dynamic Type,
VoiceOver, Reduce Motion and Increase Contrast.

**3. Functions and target audience**

See "What this app is" above. Core features:

- **Badges** — the wearer's own saved messages, shown full-screen as a sign and
  spoken on demand. Background is a colour or a photo; the photo option exists
  so the phone can be camouflaged against clothing, a feature that came directly
  from the co-design workshops.
- **Symbol Speak** — live on-device speech recognition that shows the picture
  symbol matching the word being spoken, for users who find pictures easier than
  text.
- **Photo to Speech** — an on-device image classifier suggests the word for
  something the user is looking at, to help with word-finding difficulty. It
  offers several candidates with confidence values and never speaks a guess by
  itself.
- **Symbol Library** — a browsable, searchable set of picture symbols.
- **Search** — opens Safari to look a word up in pictures, maps or a dictionary.
- **Settings / About** — voice, speech rate, display orientation, and an
  explanation of aphasia with practical tips for communication partners.

**4. Setup instructions and access**

No setup is required. There is no account, no login, no demo credentials, no
sample files and no server. Every feature is reachable from the first screen on
first launch, and the app ships with a set of starting badges so it is usable
immediately.

The only prompts are the standard iOS permission dialogs, each requested at the
point of use rather than at launch:

| Permission | Used for | Required? |
|---|---|---|
| Microphone | Symbol Speak listening | No — optional feature |
| Speech Recognition | Turning that speech into symbols | No — optional feature |
| Camera | Photographing a badge background, or a subject for Photo to Speech | No — optional feature |
| Photo Library | Choosing an existing photo for those same two features | No — optional feature |

Declining any of them leaves the rest of the app fully functional.

**5. External services, tools and platforms**

**None.** This is the complete and accurate answer.

The app contains no third-party SDKs, no analytics, no advertising, no crash
reporting, no authentication provider and no payment processing. It makes no
network requests of its own — there is no `URLSession` or equivalent networking
code anywhere in the codebase.

Specifically regarding **AI services**, since the app has a feature named "Write
badges with AI":

- That feature **does not call any AI service.** It copies a text prompt to the
  system clipboard for the user to paste into whatever assistant they already
  use, and then parses whatever the user pastes back. The app holds no API key
  and contacts no AI provider. The user chooses the assistant and can read the
  prompt before sending it.
- **Photo to Speech** uses a MobileNetV2 Core ML model bundled inside the app and
  run entirely on-device via Apple's Vision framework. No image is uploaded.
- **Symbol Speak** uses Apple's own `SFSpeechRecognizer`, preferring on-device
  recognition where the hardware supports it.
- Text-to-speech uses Apple's `AVSpeechSynthesizer` with system voices.

The only outbound activity is the Search feature and the links on the About
page, which hand a URL to Safari. Nothing is transmitted by the app itself.

All user data — badges, settings and any background photos — is stored only in
the app's own container on the device and is deleted with the app.

**6. Regional differences**

There are none. The app behaves identically in every region. There is no
geo-gating, no region-specific content and no regional pricing (the app is free).

Badges can carry an optional BCP 47 language tag so a message is spoken in a
chosen language; where no tag is set, the device language is used. The available
voices and speech-recognition locales are whatever iOS provides on that device.

**7. Regulated industry and third-party material**

**Not a medical device.** Walkie Talkie AAC makes no diagnostic, therapeutic or
clinical claim. It does not measure, monitor or treat any condition. It is a
communication aid for everyday conversation, comparable to a printed
communication card, and it states in the app and in its documentation that it is
not a medical device and not an emergency service. It operates in no regulated
industry.

**Third-party material, with permissions:**

- **Picture symbols** are from Mulberry Symbols v3.6.0, released under
  Creative Commons Attribution-ShareAlike 4.0 (CC BY-SA 4.0), which permits
  redistribution including commercially. Attribution and a link to the licence
  are shown in the app's About page and in the repository.
- **The underlying research** is the developer's own published work: Curtis, Lau
  and Neate, "Breaking Badge: Augmenting Communication with Wearable AAC
  Smartbadges and Displays", ACM CHI 2024, DOI 10.1145/3613904.3642327. No
  third-party permission is required.
- **The co-design workshops** were run in partnership with Aphasia Re-Connect and
  received King's College London Health Faculties Research Ethics Committee
  approval. Participants consented to the research.
- All other assets — icon, interface, text and code — are original.

Source code is public at <https://github.com/HumphreyCurtis/Walkie-Talkie-AAC>
and can be inspected to verify any of the above.

---

## Before resubmitting

- [ ] Record the walkthrough on the iPhone 17 Pro and attach it. Follow the
      eight steps in item 1, and **let the camera, microphone and speech
      recognition permission prompts appear on screen** — Apple asked
      specifically to see prompts for sensitive capabilities.
- [ ] Confirm App Store screenshots show the app in use — the badge display and
      the menu — not the icon or a title card (Guideline 2.3.3).
- [ ] Confirm the four permission strings each say what the data is used for
      (Guideline 5.1.1); they currently do.
- [ ] Confirm the privacy policy URL in App Store Connect resolves.
- [ ] App Privacy answers should reflect **no data collected** — nothing leaves
      the device.
