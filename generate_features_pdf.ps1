$lines = @(
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
  "The strongest commercial upgrade is: real gallery + premium menu section + birthday / party booking section + analytics-ready CTA tracking."
)

function Escape-PdfText([string]$text) {
  return $text.Replace('\', '\\').Replace('(', '\(').Replace(')', '\)')
}

$contentLines = New-Object System.Collections.Generic.List[string]
$contentLines.Add("BT")
$contentLines.Add("/F1 20 Tf")
$contentLines.Add("50 790 Td")
$first = $true

foreach ($line in $lines) {
  $safe = Escape-PdfText $line
  if ($first) {
    $contentLines.Add("($safe) Tj")
    $first = $false
  } else {
    $contentLines.Add("0 -18 Td")
    $contentLines.Add("($safe) Tj")
  }
}

$contentLines.Add("ET")
$streamText = [string]::Join("`n", $contentLines)
$streamBytes = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($streamText)

$objects = New-Object System.Collections.Generic.List[byte[]]
$enc = [System.Text.Encoding]::ASCII

$objects.Add($enc.GetBytes("1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj`n"))
$objects.Add($enc.GetBytes("2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj`n"))
$objects.Add($enc.GetBytes("3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >> endobj`n"))
$objects.Add($enc.GetBytes("4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj`n"))

$prefix = $enc.GetBytes("5 0 obj << /Length $($streamBytes.Length) >> stream`n")
$suffix = $enc.GetBytes("`nendstream endobj`n")
$obj5 = New-Object byte[] ($prefix.Length + $streamBytes.Length + $suffix.Length)
[Array]::Copy($prefix, 0, $obj5, 0, $prefix.Length)
[Array]::Copy($streamBytes, 0, $obj5, $prefix.Length, $streamBytes.Length)
[Array]::Copy($suffix, 0, $obj5, $prefix.Length + $streamBytes.Length, $suffix.Length)
$objects.Add($obj5)

$pdf = New-Object System.Collections.Generic.List[byte]
$header = $enc.GetBytes("%PDF-1.4`n")
$pdf.AddRange($header)

$offsets = New-Object System.Collections.Generic.List[int]
$offsets.Add(0)

foreach ($obj in $objects) {
  $offsets.Add($pdf.Count)
  $pdf.AddRange($obj)
}

$xrefOffset = $pdf.Count
$pdf.AddRange($enc.GetBytes("xref`n0 $($offsets.Count)`n"))
$pdf.AddRange($enc.GetBytes("0000000000 65535 f `n"))

for ($i = 1; $i -lt $offsets.Count; $i++) {
  $pdf.AddRange($enc.GetBytes(("{0:0000000000} 00000 n `n" -f $offsets[$i])))
}

$trailer = "trailer << /Size $($offsets.Count) /Root 1 0 R >>`nstartxref`n$xrefOffset`n%%EOF"
$pdf.AddRange($enc.GetBytes($trailer))

[System.IO.File]::WriteAllBytes((Join-Path $PSScriptRoot "cafooze-website-growth-features.pdf"), $pdf.ToArray())
