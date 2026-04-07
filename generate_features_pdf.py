from pathlib import Path


lines = [
    "Cafooze Restro Cafe Website Growth Features",
    "",
    "Purpose",
    "These features make the website more valuable to the client by increasing bookings, repeat visits, trust, and direct customer actions.",
    "",
    "1. Menu Page With Pricing",
    "A real menu with categories, prices, bestseller tags, and must-try items helps customers decide faster and improves local SEO.",
    "",
    "2. Reservation / Table Booking",
    "A booking form or WhatsApp reservation flow can convert visitors into table enquiries for dates, groups, and casual dining.",
    "",
    "3. Birthday / Party / Decor Packages",
    "A special section for birthdays, surprises, and small celebrations can bring higher-value bookings.",
    "",
    "4. Real Photo Gallery",
    "A premium gallery with actual cafe photos builds trust and helps the place stand out more than stock visuals.",
    "",
    "5. Google Review Highlights",
    "Curated review snippets and rating highlights create instant credibility for first-time visitors.",
    "",
    "6. Offers / Happy Hours / Combo Deals",
    "A dedicated offers section creates urgency and gives customers a reason to visit immediately.",
    "",
    "7. CTA Click Tracking",
    "Track calls, WhatsApp clicks, map opens, and Instagram clicks to show what drives business.",
    "",
    "8. Events / Special Nights",
    "Promote live screenings, music nights, date-night setups, and themed evenings to drive repeat visits.",
    "",
    "9. Delivery / Order Links",
    "Add Swiggy, Zomato, or direct ordering links for customers who prefer delivery instead of dine-in.",
    "",
    "10. Local SEO Landing Sections",
    "Create stronger keyword sections such as best cafe near Officers Club or best cafe in Pandurangapuram.",
    "",
    "11. Simple Admin Update System",
    "Allow quick updates for menu items, offers, photos, and announcements so the website stays useful over time.",
    "",
    "12. Lead Capture For Repeat Marketing",
    "Collect event enquiries, birthday requests, or offer signups for WhatsApp follow-up campaigns.",
    "",
    "Best Upsell Bundle",
    "1. Real photo gallery",
    "2. Menu with prices",
    "3. Birthday / party booking section",
    "4. Offers banner system",
    "5. Analytics and CTA tracking",
    "",
    "Recommended Next Build",
    "The strongest commercial upgrade is: real gallery + premium menu section + birthday / party booking section + analytics-ready CTA tracking.",
]


def escape_pdf_text(text: str) -> str:
    return text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


content = []
content.append("BT")
content.append("/F1 20 Tf")
content.append("50 790 Td")
leading = 18

first = True
for line in lines:
    safe = escape_pdf_text(line)
    if first:
        content.append(f"({safe}) Tj")
        first = False
    else:
        content.append(f"0 -{leading} Td")
        content.append(f"({safe}) Tj")
content.append("ET")

stream = "\n".join(content).encode("latin-1", errors="replace")

objects = []
objects.append(b"1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n")
objects.append(b"2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj\n")
objects.append(
    b"3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >> endobj\n"
)
objects.append(b"4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj\n")
objects.append(
    f"5 0 obj << /Length {len(stream)} >> stream\n".encode("latin-1")
    + stream
    + b"\nendstream endobj\n"
)

pdf = bytearray(b"%PDF-1.4\n")
offsets = [0]
for obj in objects:
    offsets.append(len(pdf))
    pdf.extend(obj)

xref_offset = len(pdf)
pdf.extend(f"xref\n0 {len(offsets)}\n".encode("latin-1"))
pdf.extend(b"0000000000 65535 f \n")
for off in offsets[1:]:
    pdf.extend(f"{off:010d} 00000 n \n".encode("latin-1"))
pdf.extend(
    (
        f"trailer << /Size {len(offsets)} /Root 1 0 R >>\n"
        f"startxref\n{xref_offset}\n%%EOF"
    ).encode("latin-1")
)

Path("cafooze-website-growth-features.pdf").write_bytes(pdf)
