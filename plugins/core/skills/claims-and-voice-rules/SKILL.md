---
name: claims-and-voice-rules
description: The hard copy rules every client gets by default (no em dashes, write the number not the adjective, "as much as" never "up to", never invent facts, no fake testimonials, AI presenters never framed as customers), the pattern for a client's approved-claims list and voice file (what goes in voice.yaml), and the check every skill runs on copy before it ships, with a script that flags banned words, em dashes, "up to" and number claims not on the approved list. Use it before writing or approving any copy: ads, social posts, end cards, scripts, emails.
---

# Claims and voice rules

Copy goes wrong in two ways: it says something the client cannot back up, or it does not sound like the client. Both are fixed the same way: a short file of rules and approved claims per client, plus a check before anything ships. This skill holds the defaults every client gets, the shape of that file, and the check. The result is copy that passed the check, or a list of exactly what failed.

## Config
This skill needs: `voice.yaml` (keys: `voice.tone`, `voice.person`, `voice.banned_words`, `voice.banned_phrases`, `voice.rules`, `voice.approved_claims`, `voice.claim_rules`, `voice.spoken_variants`, `voice.do_not`, `voice.examples`), and `references.yaml` (keys: `banned_assets`).
Look in this order: see `core/client-config`. With an empty `voice.yaml` the default hard rules below still apply. Without `voice.approved_claims`, any claim with a number has to be confirmed by the owner before it ships; say which ones.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the voice file
- `core/house-report`: name every claim you could not confirm

## The hard rules (every client, by default)
A client's `voice.yaml` can add rules. It removes a default only by saying so in `voice.rules`.

1. **No em dashes.** Not as a pause, not as a list marker. Use a comma, a colon, a full stop or brackets. Readers spot it at once as machine-written.
2. **Write the number, not the adjective.** "Lasts 2 years" beats "long-lasting". Specific beats impressive.
3. **"As much as", never "up to".** "As much as 30% faster", never "up to 30%". Check translations too: the word for "up to" comes back through translation. List its translated forms per language in `claim_rules`.
4. **Never invent.** No made-up facts, numbers, names, dates, prices or commitments. If something is missing, leave a visible `[placeholder]` and say so when handing over.
5. **No fake testimonials.** Nobody in an image, video or caption is framed as a customer unless they are one and agreed to it. An AI presenter speaks as a presenter ("This <product> <does the benefit>"), never as a buyer ("I bought this").
6. **No superlatives without a source.** Awards in their exact official wording (a finalist is not a winner). No "the biggest award in the world".
7. **No capability the product does not have.** Say exactly what it does (for example "reduces" is not "removes").
8. **One language per piece.** Every word in the image or script in the brief's language. Translations follow the same approved claims.
9. **Plain words, short sentences, the point first.** No fluff openers, no hype words, no emoji in ad images unless the client's voice allows them.

## The voice file: what goes in `voice.yaml`
| Key | What goes in it |
|---|---|
| `tone` | One line: how it should sound and what it never does ("professional, factual, no hype, no exclamation marks, no emojis"). |
| `person` | Who speaks: "we", "I", or the brand name. |
| `banned_words`, `banned_phrases` | Words and openers this client never uses, verbatim. |
| `rules` | Extra house rules, one line each. |
| `approved_claims` | **The only claims allowed in copy, verbatim, per language.** Proof points in ads come only from here. |
| `claim_rules` | How claims may be phrased: the "as much as" rule, which use case leads and which comes last, award wording, what the product does not do. |
| `spoken_variants` | Claims that read well but sound wrong spoken. Example: keep the percentage on the end card and say a plain phrase in speech. |
| `do_not` | Habits that break this voice ("a closing paragraph that restates the email", "over-polishing informal replies into neutral business English"). |
| `examples` | Verbatim pieces the owner approved, with where each was used. The strongest guide to the voice. |
| `person_voice` | Only for a voice written as one person (emails sent as them): greetings and sign-offs by situation, signposting lines, how the register shifts internal against external. Keep it in the private config repo. |

How to build one for a new client:
1. Collect 5 to 10 pieces the client already approved (posts, emails, ads).
2. Write `tone` and `person` from them. Pull `banned_phrases` from what they never say, and `do_not` from edits they made to drafts.
3. Copy every claim from the client's own product or claims document into `approved_claims`, verbatim, with its source. Nothing goes in from memory or from a competitor.
4. Write `claim_rules` with the client: how numbers are phrased, award wording, what leads.
5. Put the pieces into `examples`.

## Steps: checking copy before it ships
1. Run the checker: `python3 scripts/check_copy.py <copy.txt> --voice <path to voice.yaml>`. It fails on em dashes, "up to" with a number, banned words and phrases, placeholders, and number claims not on `approved_claims`. It warns on emoji, banned exclamation marks and testimonial-like first person. Fix every FAIL; decide every WARN.
2. Read the copy against `claim_rules` and the hard rules by hand. The script cannot judge what leads, what is implied, or how a sentence sounds.
3. For spoken copy, check `spoken_variants`, and read it aloud.
4. Check every asset that carries words of its own (a video with text baked in, an old end card) against the current claims. Assets with outdated claims baked in go into `banned_assets`.
5. For a brief, Headline, Subhead and Primary text are checked when the brief is written (`core/brief-contract`), and the image text again before upload.
6. Report the result: passed, or the exact lines that failed and the claims you could not confirm.

## Output
Copy that passed the check, or a list of failures and unconfirmed claims for the owner.

## Known failures
- **A hero video could never be used again.** It had an "up to" claim baked into the footage. Fix: check assets, not only text (step 4); it went into `banned_assets`.
- **Risk: a percentage that reads well but sounds wrong spoken** (one language's scripts avoid it in speech). Fix: a plain phrase in speech and the percentage on the end card (`spoken_variants`).
- **Risk: "up to" returning through translation.** Fix: hard rule 3 and the translated forms in `claim_rules`; the checker only catches English.
- **Risk: one English word in a non-English image.** Fix: hard rule 8, checked before upload.
- **Risk: an AI presenter scripted as a happy customer.** Fix: hard rule 5.
- **Risk: award wording drifting upward** ("winner" for a finalist, "biggest award in the world"). Fix: hard rule 6 and exact wording in `claim_rules`.
- **Risk: a personal voice polished into neutral business English.** The small informalities are the voice. Fix: `do_not` and `examples`.

## References
- `scripts/check_copy.py`: the checker (Python standard library; uses PyYAML if installed).
- `templates/client-config/voice.yaml` in the toolkit repo: the empty voice file.
