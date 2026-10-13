---
name: file-delivery
description: How to hand finished files to the user and put them onto their machine or cloud folder safely. Covers naming and versions, the per-file size limit and splitting large files, never deleting (move to a scratch folder instead), checking that every file landed by listing the folder, recovering from a partial write, and checking Drive links by title. Use it whenever a skill produces a file (image, video, document, project file) that has to reach the user or a shared folder.
---

# File delivery

Every skill that makes something ends the same way: the file reaches the user, lands in the right folder, and the report says exactly where. This skill holds those steps and the gotchas that broke them before. The result is files the user can open, in the folder the config names, checked one by one.

## Config
This skill needs: `brand.yaml` (keys: `drive.outputs`, `drive.device_path_prefix`, `drive.route`, `drive.scratch`), plus the calling skill's naming pattern (for example `video.naming`).
Look in this order: see `core/client-config`. If `drive.outputs` is missing, deliver to the user only and say the folder copy was skipped. If `drive.scratch` is missing, ask where files may be moved instead of deleted; never delete as a fallback.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the folder keys and the route
- `core/platform-adapters` for "deliver the file to the user", "write file to device", "list a folder on the user's machine", "run a shell command on the user's machine", "search Drive"
- `core/house-report` for the final report

## Inputs
The finished files, the folder they belong in, and the calling skill's naming pattern.

## Steps
1. **Name every file** by the calling skill's pattern, with a version (`_v<N>`). With no pattern, use `<short-description>_<YYYY-MM-DD>_v<N>.<ext>`. Never overwrite a version the owner has already seen; bump the version instead. If the computed name already exists in the folder, stop and ask.
2. **Check the file before it leaves.** Run the calling skill's quality check. For documents exported to PDF, run the export check in `references/document-export.md`.
3. **Deliver to the user** ("deliver the file to the user"). Some platforms first need the file in their outputs folder (see `core/platform-adapters`). On some platforms this step returns a file ID that the next step needs; keep it.
4. **Write onto the user's machine or cloud folder** ("write file to device"), into `drive.outputs` under `drive.device_path_prefix`. Follow `drive.route` (see `core/client-config`). In a cloud or scheduled run with no machine linked, skip this step and say so.
5. **Respect the size limit.** A single write onto the user's machine can be capped (30 MB per file on the Claude app's device bridge). For a larger file:
   1. Split it into parts under the cap. For video: `ffmpeg -i in.mp4 -f segment -segment_time 14 -reset_timestamps 1 -c copy part_%03d.mp4`.
   2. Write the parts into `<drive.scratch>/parts/<name>/`.
   3. Join them on the machine ("run a shell command on the user's machine"). For video: list the parts in `list.txt` (`file 'part_000.mp4'` per line) and run `ffmpeg -f concat -safe 0 -i list.txt -c copy <final name>`.
   4. Check the joined file is whole. For video: the frame count (`ffprobe -v error -count_packets -select_streams v:0 -show_entries stream=nb_read_packets -of csv=p=0 <file>`) equals the original's.
   5. Move the parts into scratch once the check passes (step 6).
6. **Never delete.** Move unwanted files into `drive.scratch` with `mv -n` (never overwrite). Deleting on the user's machine often fails without permission, and it cannot be undone. Delete only when the owner has approved that specific delete.
7. **Never touch the owner's files.** Only create new files. Never rename, overwrite or move a file you did not create in this run. Steps the owner keeps for themself (for example renaming an invoice once it is paid) are never done by the agent.
8. **Check that every file landed.** List the folder ("list a folder on the user's machine"). Each expected file must be there, with the expected size. A write tool saying "success" is not proof.
9. **Recover from a partial write.** If the link to the machine drops, or a write returns with fewer files than sent: list the folder, compare it with the list of expected files, and write only the missing ones. Then list again.
10. **Check every link before sending it.** For a Drive link: "search Drive" by the file's title, open the result, and check that the title and the version match the file you made.
11. **Report** in the house format: what was delivered, the folder path or link for each file, and anything skipped.

## Output
The files delivered to the user, the same files in the configured folder (or a note that the copy was skipped), and a report with the exact path or link of each one.

## Known failures
- **A delete failed on the user's machine.** Cause: deleting needs a permission the agent does not have. Fix: move into scratch (step 6).
- **A large video would not write.** Cause: the per-file cap (30 MB on the Claude app's device bridge). Fix: split, write the parts, join on the machine, check the frame count (step 5).
- **One write call put 2 of 3 files in the folder.** Cause: the link to the machine dropped mid-run. Fix: list, compare, write only what is missing (step 9).
- **Risk: a link in the report opens an older version.** A Drive search can match an earlier file with a similar name. Fix: check the title and version before sending (step 10).
- **An image arrived corrupted.** Cause: image bytes or base64 were passed through the agent's own messages. Fix: move files only with file tools or by URL. A Drive download can come back as base64 inside JSON (files up to about 10 MB); decode it with a script, not by copying text.
- **A folder search found nothing.** Cause: the Drive connector was signed in to a different account than the folder's owner. Fix: follow `drive.route`.
- **A long join or render was killed half way.** Cause: on the Claude app's device bridge, every shell process ends when the call returns; background tricks (`nohup`, `setsid`) do not help. Fix: work in chunks that each finish inside one call, and resume.
- **Risk: the device shell cannot see a drive.** The shell can fail to mount a volume. Fix: read and write through the file tools instead.
- **Rows were cut off in an exported PDF.** Cause: table rows set to an exact height. Fix: `references/document-export.md`.

## References
- `references/document-export.md`: editing a .docx safely, the row-height fix, the PDF export with `soffice`, and the `pdftoppm` render check.
