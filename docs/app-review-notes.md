Paste everything below the rule into App Store Connect — both as the reply to
App Review, and into App Review Information → Notes for future submissions.
Under 4,000 characters. Attach the screen recording to the reply separately.

---

A free AAC (Augmentative and Alternative Communication) aid. It turns an iPhone worn on a lanyard or arm strap into an outward-facing sign: the wearer shows a message to the person they are speaking to, and can have the phone speak it aloud.

It is for people with aphasia — a communication disability, usually after a stroke, that makes speaking, reading or writing difficult without affecting intelligence. In a shop or on public transport the wearer may be unable to produce a sentence; the app shows it instead, and explains their disability for them.

Co-designed with people with aphasia alongside Aphasia Re-Connect (UK charity 1176125), based on the developer's own research (ACM CHI 2024, DOI 10.1145/3613904.3642327).

1. SCREEN RECORDING
Attached, captured on iPhone 17 Pro running iOS 26.5.2. There are no account, login, purchase or user-generated-content flows, so none appear. Camera, microphone and speech recognition prompts do.
It shows: launch; opening a badge (fills the screen, rotated 180° to face the reader, tap to speak); changing its colour and adding a photo background; creating a badge; then Symbol Speak, Photo to Speech, Search, Settings and About.

2. DEVICES TESTED
iPhone 17 Pro, iOS 26.5.2 — physical device.
iPhone 15 and iPad (10th generation), iOS 17.0.1 simulators — the minimum deployment target, so the oldest supported setup is covered too.
Built with Xcode 26.6 against the iOS 26.5 SDK. Supports iPhone and iPad on iOS 17.0+.

3. FUNCTIONS
Badges — saved messages shown full-screen as a sign and spoken on demand. The background is a colour or photo, so the phone can be camouflaged against clothing.
Symbol Speak — on-device speech recognition showing the picture symbol for each word spoken.
Photo to Speech — an on-device model suggests the word for a photographed object, for word-finding.
Symbol Library — browsable, searchable picture symbols.
Search — opens Safari to look up a word.
Settings and About — voice, speed, orientation, and an aphasia explainer.

4. SETUP AND ACCESS
None required. No account, login, demo credentials, sample files or server. Every feature is reachable from the first screen on launch, and starting badges ship with the app.
The only prompts are standard iOS permissions, at point of use: Microphone and Speech Recognition for Symbol Speak; Camera and Photo Library for badge backgrounds and Photo to Speech. All optional — declining leaves the rest working.

5. EXTERNAL SERVICES
None. No third-party SDKs, analytics, advertising, crash reporting, authentication or payments. The app makes no network requests — there is no URLSession or equivalent in the code.
On AI: the "Write badges with AI" feature calls no AI service. It copies a prompt to the clipboard for the user to paste into an assistant of their choosing, then parses what they paste back. No API key, no provider.
Photo to Speech uses a bundled Core ML model on-device via Vision. Symbol Speak uses SFSpeechRecognizer. Speech uses AVSpeechSynthesizer.
The only outbound activity is Search and the About links handing a URL to Safari. All user data stays in the app container and is deleted with the app.

6. REGIONAL DIFFERENCES
None — behaviour is identical everywhere. No geo-gating, region-specific content or regional pricing (it is free). Badges may carry an optional language tag for speech; otherwise the device language is used.

7. REGULATED INDUSTRY AND THIRD-PARTY MATERIAL
Not a medical device. It makes no diagnostic, therapeutic or clinical claim and does not measure, monitor or treat any condition. It is a communication aid comparable to a printed communication card, and says so in-app.
Picture symbols are Mulberry Symbols v3.6.0 under CC BY-SA 4.0, which permits commercial redistribution; attributed in the About page.
The research is the developer's own published work. The co-design workshops had King's College London ethics approval. All other assets are original.
Source: github.com/HumphreyCurtis/Walkie-Talkie-AAC
