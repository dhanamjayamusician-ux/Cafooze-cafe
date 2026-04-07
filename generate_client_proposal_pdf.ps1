$lines = @(
  "Cafooze Restro Cafe",
  "Website Growth Proposal",
  "",
  "Prepared for Client Presentation",
  "",
  "Goal",
  "Turn the website into a premium business asset that increases walk-ins, bookings, repeat visits, and direct customer enquiries.",
  "",
  "What The Website Should Do",
  "- Build trust at first glance",
  "- Show the cafe ambience and vibe clearly",
  "- Make it easy to call, chat, visit, or book",
  "- Support birthday, date-night, and group enquiries",
  "- Help the cafe win more local attention online",
  "",
  "Recommended Upgrade Features",
  "1. Premium menu section with categories, prices, and bestseller tags",
  "2. Reservation or table booking flow",
  "3. Birthday surprise and party booking section",
  "4. Real gallery with cafe interiors, food, drinks, and decor",
  "5. Review highlight section using real guest feedback",
  "6. Offers and combo banner system",
  "7. Click tracking for calls, WhatsApp, maps, and Instagram",
  "8. Events or special nights section",
  "9. Delivery or food ordering links",
  "10. Local SEO content for location-based search terms",
  "11. Simple admin update system for offers and menu changes",
  "12. Lead capture for repeat promotions and event enquiries",
  "",
  "High-Value Client Benefits",
  "- More enquiries for birthdays, surprises, and group bookings",
  "- Better conversion from Instagram, Maps, and WhatsApp traffic",
  "- Stronger trust through real photos and reviews",
  "- More repeat visits through offers and event promotion",
  "- Better visibility for local search around Officers Club and Pandurangapuram",
  "",
  "Recommended Packages",
  "",
  "Package 1: Conversion Upgrade",
  "Menu section + real gallery + stronger CTA layout + review highlights",
  "Best for making the current website more convincing immediately.",
  "",
  "Package 2: Booking Upgrade",
  "Everything in Conversion Upgrade + birthday and party enquiry section + reservation flow",
  "Best for generating direct leads and higher-ticket bookings.",
  "",
  "Package 3: Growth Upgrade",
  "Everything in Booking Upgrade + offers system + analytics tracking + event promotions + local SEO enhancements",
  "Best for long-term business growth and measurable marketing value.",
  "",
  "Recommended Next Phase",
  "Start with: real gallery + menu with prices + birthday or party booking section + CTA tracking.",
  "This is the strongest balance of visual value, business impact, and upsell potential.",
  "",
  "Positioning For Client Discussion",
  "This is not only a website upgrade.",
  "It becomes a digital sales tool for discovery, trust, and customer action.",
  "",
  "Prepared By",
  "Website and brand growth proposal for Cafooze Restro Cafe."
)

function Escape-PdfText([string]$text) {
  return $text.Replace('\', '\\').Replace('(', '\(').Replace(')', '\)')
}

$contentLines = New-Object System.Collections.Generic.List[string]
$contentLines.Add("BT")
$contentLines.Add("/F1 18 Tf")
$contentLines.Add("46 795 Td")
$first = $true

foreach ($line in $lines) {
  $safe = Escape-PdfText $line
  if ($first) {
    $contentLines.Add("($safe) Tj")
    $first = $false
  } else {
    $contentLines.Add("0 -17 Td")
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

[System.IO.File]::WriteAllBytes((Join-Path $PSScriptRoot "cafooze-client-growth-proposal.pdf"), $pdf.ToArray())
