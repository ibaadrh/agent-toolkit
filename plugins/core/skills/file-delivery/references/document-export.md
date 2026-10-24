# Document export: .docx edits and PDF export

For any Word template that gets reused: copy last time's .docx, change only what must change, export a PDF.

## Edit only what must change
- Copy the template to the new file name first. Never edit the template itself.
- Replace text by targeted match on the exact phrase (for example the line that starts "Invoice #", or the period sentence). Never run a general "replace any number" pass: bank account numbers and IBANs are long digit strings too.
- Leave Word fields alone. A "Date:" line can be a live field (`{ DATE \@ "DD/MM/yy" }`), not typed text. Find it in the XML (`w:fldChar` and `w:instrText` containing `DATE`) and never edit that run. LibreOffice recalculates fields when it opens the file, so the PDF shows today's date.
- If an amount changes, change its total and the subtotal too.

## The row-height fix (before every PDF export)
Templates often set table rows to an exact height. In Word that looks fine. When LibreOffice converts to PDF, any row whose text needs a little more room gets clipped at the top. Change the rule from "exactly" to "at least"; the heights stay the same and only rows that need room grow.

```python
import docx
from docx.enum.table import WD_ROW_HEIGHT_RULE

d = docx.Document(path)
for t in d.tables:
    for r in t.rows:
        r.height_rule = WD_ROW_HEIGHT_RULE.AT_LEAST
d.save(path)
```

Run it on the same file that holds the text edits, right before the export.

## Export and check
1. Export: `soffice --headless --convert-to pdf --outdir <out folder> <file>.docx`
2. Render page 1 to an image: `pdftoppm -png -r 110 -f 1 -l 1 <file>.pdf page`
3. Look at the image. Check that no row or line is clipped, and that a date field shows today's date, not a stale one.
4. Only then deliver it (`core/file-delivery`).

## Known failures
- **Clipped header, period line and subtotal rows in the PDF.** Cause: exact-height rows in the template, present even in untouched old files. Fix: the row-height fix above.
- **Risk: a stale date in the PDF.** Cause: the date field was replaced with typed text, or the converter did not evaluate fields. Fix: leave the field alone and check the rendered page.
