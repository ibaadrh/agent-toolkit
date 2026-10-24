---
name: claims-and-voice-rules
description: The truthfulness rules every client gets (never invent facts, approved claims only, no fake testimonials, AI presenters never framed as customers, awards in their exact wording, no capability the product lacks), the author's default copy rules (no em dashes, write the number not the adjective, "as much as" never "up to", plain words), the pattern for a client's approved-claims list and voice file (what goes in voice.yaml), and the check every skill runs on copy before it ships, with a script that flags em dashes, "up to" with a number, banned words and number claims not on the approved list. Use it before writing or approving any copy: ads, social posts, end cards, scripts, emails.
---

# Claims and voice rules

Copy goes wrong in two ways: it says something the client cannot back up, or it does not sound like the client. Both are fixed the same way: a short file of rules and approved claims per client, plus a check before anything ships. This skill holds the truthfulness rules that apply to everyone, the author's default copy rules, the shape of that file, and the check. The client's own tone, person, banned words and examples come from their voice file. The result is copy that passed the check, or a list of exactly what failed.

## Config
This skill needs: `voice.yaml` (keys: `voice.tone`, `voice.person`, `voice.banned_words`, `voice.banned_phrases`, `voice.rules`, `voice.approved_claims`, `voice.claim_rules`, `voice.spoken_variants`, `voice.do_not`, `voice.examples`), and `references.yaml` (keys: `banned_assets`).
Look in this order: see `core/client-config`. With an empty `voice.yaml`, the truthfulness rules and the default copy rules below still apply; ask the owner for tone and person before writing more than a draft, and never borrow another client's. Without `voice.approved_claims`, any claim with a number has to be confirmed by the owner before it ships; say which ones.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the voice file
- `core/house-report`: name every claim you could not confirm

## The truthfulness rules (every client)
These are about what copy may claim, not how it sounds. A client cannot switch them off.

1. **Never invent.** No made-up facts, numbers, names, dates, prices or commitments. If something is missing, leave a visible `[placeholder]` and say so when handing over.
2. **Approved claims only.** A claim with a number, a comparison or a result comes from `voice.approved_claims`, verbatim, phrased as `voice.claim_rules` allows.
3. **No fake testimonials.** Nobody in an image, video or caption is framed as a customer unless they are one and agreed to it. An AI presenter speaks as a presenter ("This <product> <does the benefit>"), never as a buyer ("I bought this").
4. **No superlatives without a source.** Awards and certifications in their exact official wording (a finalist is not a winner).
5. **No capability the product does not have.** Say exactly what it does (for example "reduces" is not "removes").
6. **The language the brief sets.** Every word in an image or script is in the language the brief or the client sets. Translations use the same approved claims.

## The default copy rules (default; a client's config can override)
These are the author's own copy rules. A client's `voice.yaml` can add rules, and removes a default only by saying so in `voice.rules`.

1. **No em dashes.** Not as a pause, not as a list marker. Use a comma, a colon, a full stop or brackets. Readers spot it at once as machine-written.
2. **Write the number, not the adjective.** "Lasts 2 years" beats "long-lasting". Specific beats impressive.
3. **"As much as", never "up to".** "As much as 30% faster", never "up to 30%". Check translations too: the word for "up to" comes back through translation. List its translated forms per language in `claim_rules`.
4. **Plain words, short sentences, the point first.** No fluff openers, no hype words, no emoji in ad images unless the client's voice allows them.

## The voice file: what goes in `voice.yaml`

| Key | What goes in it |
|---|---|
| `tone` | One line: how it should sound and what it never does. |
| `person` | Who speaks: "we", "I", or the brand name. |
| `banned_words`, `banned_phrases` | Words and openers this client never uses, verbatim, per language. The checker fails on every one. |
| `rules` | Extra house rules, one line each, and any default rule this client switches off. |
| `approved_claims` | **The only claims allowed in copy, verbatim, per language.** Proof points in ads come only from here. |
| `claim_rules` | How claims may be phrased: the "as much as" rule and its translated forms, which use case leads, award wording, what the product does not do. |
| `spoken_variants` | Claims that read well but sound wrong spoken, with the spoken form. |
| `do_not` | Habits that break this voice, one line each. |
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
2. Read the copy against `voice.rules`, `claim_rules`, the default copy rules and the truthfulness rules by hand. The script cannot judge what leads, what is implied, or how a sentence sounds.
3. For spoken copy, check `spoken_variants`, and read it aloud.
4. Check every asset that carries words of its own (a video with text baked in, an old end card) against the current claims. Assets with outdated claims baked in go into `banned_assets`.
5. For a brief, Headline, Subhead and Primary text are checked when the brief is written (`core/brief-contract`), and the image text again before upload.
6. Report the result: passed, or the exact lines that failed and the claims you could not confirm.

## Output
Copy that passed the check, or a list of failures and unconfirmed claims for the owner.

## Known failures
- **A video could never be used again.** It had an outdated claim baked into the footage. Fix: check assets, not only text (step 4); it went into `banned_assets`.
- **Risk: a claim that reads well but sounds wrong spoken.** Fix: `spoken_variants`.
- **Risk: "up to" returning through translation.** Fix: default rule 3 and the translated forms in `claim_rules`; the checker only catches English.
- **Risk: one word in the wrong language in an image.** Fix: truthfulness rule 6, checked before upload.
- **Risk: an AI presenter scripted as a happy customer.** Fix: truthfulness rule 3.
- **Risk: award wording drifting upward** ("winner" for a finalist). Fix: truthfulness rule 4 and exact wording in `claim_rules`.
- **Risk: a personal voice polished into neutral business English.** The small informalities are the voice. Fix: `do_not` and `examples`.
- **Risk: one client's tone applied to another.** Fix: tone, person and examples live only in each client's voice file; an empty file means ask.

## References
- `scripts/check_copy.py`: the checker (Python standard library; uses PyYAML if installed).
- `templates/client-config/voice.yaml` in the toolkit repo: the empty voice file.
