# ScamShield India

![CI](https://github.com/IMxPratham/Scam-Shield-India/actions/workflows/ci.yml/badge.svg)

A Flutter app that checks a suspicious SMS or link and returns a **0-100 risk
score**, a verdict, plain-English reasons, and what to do next.

- Runs **fully on your phone**. No server, no account, no machine learning.
- Uses **transparent weighted rules**. Every point in the score is explained.
- Built for scams common in India: fake KYC messages, UPI collect requests,
  fake bank links, lottery and cashback bait.

> This app gives a risk estimate, not a guarantee. It cannot catch every scam,
> and a low score does not mean a message is safe. Never share your OTP, PIN
> or CVV with anyone.

## Screenshots

All messages shown are fake examples written for testing.

<p align="center">
  <img src="docs/screenshots/home.jpeg" width="160" alt="Home screen with a pasted fake scam message">
  <img src="docs/screenshots/result_high.jpeg" width="160" alt="High risk result, score 100">
  <img src="docs/screenshots/result_suspicious.jpeg" width="160" alt="Suspicious result, score 40">
  <img src="docs/screenshots/result_safe.jpeg" width="160" alt="Likely safe result, score 0">
  <img src="docs/screenshots/history.jpeg" width="160" alt="Scan history list">
</p>

From left to right: home, high risk, suspicious, likely safe, history.

## How the score works

Each rule that matches adds points. The total is capped at 100, and the reasons
are shown from the biggest contribution to the smallest.

| Score  | Verdict     |
| ------ | ----------- |
| 0-29   | Likely safe |
| 30-59  | Suspicious  |
| 60-100 | High risk   |

**Worked example.** The fake message
`Your cashback is ready. Check details at www.freeoffer-deals.top` scores 40:

| Reason                                  | Points |
| --------------------------------------- | ------ |
| Claims a prize, lottery or cashback     | +20    |
| Link has a suspicious ending (`.top`)   | +15    |
| Contains a link                         | +5     |
| **Total** (Suspicious)                  | **40** |

### Message text rules

| Rule                                  | Points | Example trigger (fake)            |
| ------------------------------------- | ------ | --------------------------------- |
| Asks for OTP, PIN, CVV or password    | +25    | "share otp", "your upi pin"       |
| Creates urgency or threatens you      | +15    | "urgent", "suspended", "blocked"  |
| Claims a prize, lottery or cashback   | +20    | "you have won", "lucky draw"      |
| KYC or account verification request   | +20    | "update kyc", "kyc pending"       |
| UPI collect / money request           | +20    | "collect request", "send rs"      |
| Legal / arrest threat                 | +20    | "arrest warrant", "court notice"  |
| Asks you to call a number             | +10    | "call this number"                |
| Contains a link                       | +5     | "http://..." or "www...."         |

Warnings such as "do not share your OTP" are excluded from the OTP rule, so
genuine bank reminders are not flagged.

### Link rules

The app finds every link in the message and scores each one separately. Only
the **highest-scoring link** counts, so five links do not add up to five times
the points.

| Rule                                                          | Points |
| ------------------------------------------------------------- | ------ |
| Looks like a fake copy of a known brand domain (1-2 typos)    | +35    |
| Brand name in the link, but the real site is a different one  | +30    |
| Uses an IP address instead of a website name                  | +25    |
| Contains punycode (`xn--`), which can hide look-alike letters | +25    |
| Has an `@` symbol (the real site is the part after it)        | +20    |
| Shortened link (bit.ly and similar)                           | +15    |
| Suspicious ending: `.xyz`, `.top`, `.click`, `.icu`           | +15    |
| Domain has 2 or more hyphens                                  | +10    |
| More than 3 subdomains                                        | +10    |
| Link starts with `http://` (not HTTPS)                        | +10    |
| Link is longer than 75 characters                             | +5     |

**Look-alike detection.** The app compares the link's main domain with a small
list of official domains using the Levenshtein edit distance: the number of
single-letter changes (insert, delete, replace) needed to turn one word into
another. A distance of 1 or 2 means "very close but not the same", for example
`sbl.co.in` against `sbi.co.in`. The Levenshtein function is written from
scratch, without a package.

**Brands covered:** State Bank of India, HDFC Bank, ICICI Bank, Axis Bank and
Paytm. The official domains are listed in `lib/detectors/url_rules.dart`.

## Architecture

```mermaid
flowchart TD
    UI["UI screens<br/>home, result, history, about"] --> P["ScanProvider<br/>(state, Provider package)"]
    P --> S["ScanService<br/>runs detectors, sums points, caps at 100"]
    S --> T["TextDetector"]
    S --> U["UrlDetector"]
    U --> D["domain_utils + levenshtein"]
    P --> R["ScanRepository"]
    R --> DB[("SQLite<br/>scans table")]
```

### Folder structure

```
lib/
  core/        detector.dart              Detector interface, Finding, DetectionResult
  detectors/   text_rules.dart            keyword rules as data
               text_detector.dart
               url_rules.dart             brands, shorteners, TLD lists as data
               url_detector.dart
  services/    scan_service.dart          runs all detectors, builds the score
               domain_utils.dart          extract host, registrable domain, subdomains
               levenshtein.dart           edit distance, written by hand
  data/        app_database.dart          opens the SQLite database
               scan_repository.dart       save, get all, delete all
               scan_record.dart           one saved scan
  providers/   scan_provider.dart         state shared with the screens
  ui/screens/  home, result, history screens
test/          unit tests for detectors, utilities, service, provider, record
```

### Design decisions

- **Strategy pattern.** Every analyzer implements the same small interface:

  ```dart
  abstract class Detector {
    String get name;
    List<Finding> analyze(String input);
  }
  ```

  `ScanService` receives a list of detectors, so a new analyzer can be added by
  writing one new class and adding it to the list. The existing detectors do not
  change.
- **Rules are data, logic is code.** Keywords, brands and lists live in
  `text_rules.dart` and `url_rules.dart`. Changing a rule does not touch the
  matching code.
- **Explainable by design.** A `Finding` is a reason plus points. The score is
  only the sum of findings, so the screen can always show why.
- **On-device only.** No message is sent anywhere.

## Privacy design

- Analysis happens on the phone. The app does not upload your message.
- History stores only a **preview of the first 100 characters**, the score, the
  verdict, the reasons and the time. The full message is not saved.
- The History screen has a **delete all** button.
- The app does not read your SMS inbox. You paste what you want to check.

Limits of this design: the database is **not encrypted**, and a 100-character
preview can still contain a phone number or part of an OTP. Do not paste
messages you are not comfortable having on your phone.

## Tests and CI

- **101 unit tests** across 7 files: text detector, URL detector, domain
  utilities, Levenshtein, scan service, scan provider and scan record.
- GitHub Actions runs `flutter analyze` and `flutter test` on every push and
  pull request to `main`, using a pinned Flutter version (3.44.9).
- Tests use made-up messages only.

## Run it yourself

Requirements: Flutter 3.44.9 (stable) and an Android phone with USB debugging.

```powershell
git clone https://github.com/IMxPratham/Scam-Shield-India.git
cd Scam-Shield-India
flutter pub get
flutter analyze
flutter test
flutter run
```

Run the app on a real Android device or emulator. The history screen uses
`sqflite`, which does not work in a web browser.

## Known limitations

This is a rule-based tool, so it is easy to fool and it makes mistakes. These
are the problems I know about.

**Message text rules**
- Rules match exact phrases. Rewording (for example "update your KYC" instead of
  "update KYC") can slip past them.
- False positives: "pay Rs" in a friendly message, and "expired" in a normal
  calendar note, are flagged.
- The "do not share" exception looks at the whole message, so a scammer could
  add that phrase to hide a request for an OTP.
- The text "contains a link" rule only sees `http://`, `https://` and `www.`,
  so bare domains are missed there.

**Link rules**
- Only 5 brands are covered. The official domain lists have **not been
  independently verified in a browser**, so do not treat them as complete.
- Not detected: hidden IP forms such as `http://3232235777`, bare IP addresses
  without `http://`, and brand names without separators such as `sbikyc.xyz`.
- The "no HTTPS" rule only fires when the link starts with `http://`.
- Short domains may be flagged as a look-alike of a short brand domain. This
  was reasoned through by hand and is not yet covered by a test.
- A link at the end of a sentence without a space, such as `Pay now.Click here`,
  may be read as a `.click` link (reasoned by hand, not yet tested).
- Brand name in the path of a legitimate news page can add +30.
- Domain handling covers common Indian suffixes such as `co.in`. Suffixes from
  other countries are not handled.
- One link can be counted by both the text rule (+5) and the link rules.

**Engineering**
- The database is not encrypted.
- No automated tests yet for the repository or the screens.
- If a detector throws an error, the scan fails.
- Tests that check exact totals must be updated whenever points change.

## Not built yet

- Opt-in link expander that follows short links. Expanding a link contacts the
  scammer's server, so it will be off by default and clearly explained.
- Repository tests with an in-memory database.

## What to do if you receive a scam

- Do not click the link, call the number or share any OTP, PIN or CVV.
- Report cyber fraud on the national helpline **1930** or at
  **cybercrime.gov.in**.
- If money was taken, call your bank immediately.

## Ethics and scope

ScamShield India is a defensive tool. It only analyzes text you paste in. It
does not read your inbox, scan networks or interact with other systems.

---

Built by [IMxPratham](https://github.com/IMxPratham) as a learning project in
mobile security and clean software design.
