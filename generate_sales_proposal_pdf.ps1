$lines = @(
  "Cafooze Restro Cafe",
  "Website Upgrade Sales Proposal",
  "",
  "Client Proposal",
  "",
  "Objective",
  "Upgrade the website into a premium business asset that helps increase walk-ins, bookings, party enquiries, repeat visits, and direct customer actions.",
  "",
  "Why This Matters",
  "- Stronger first impression for new customers",
  "- Better conversion from Instagram, Maps, and WhatsApp traffic",
  "- More birthday, date-night, and group booking enquiries",
  "- Better trust through photos, reviews, and clear contact paths",
  "- More repeat visits through offers, events, and promotions",
  "",
  "Recommended Packages",
  "",
  "Package 1: Premium Presence",
  "Includes: visual polish, real photo gallery, menu section with pricing, improved call-to-action flow, and review highlights.",
  "Suggested Price: Rs. 12,000 to Rs. 18,000",
  "Best for: cafes that want a stronger premium online presence quickly.",
  "",
  "Package 2: Booking Growth",
  "Includes: everything in Premium Presence plus reservation flow, birthday or party enquiry section, and WhatsApp lead capture.",
  "Suggested Price: Rs. 20,000 to Rs. 30,000",
  "Best for: cafes that want direct enquiries and higher-value bookings.",
  "",
  "Package 3: Business Growth System",
  "Includes: everything in Booking Growth plus offers system, event promotion section, CTA analytics tracking, and local SEO expansion.",
  "Suggested Price: Rs. 35,000 to Rs. 55,000",
  "Best for: businesses that want measurable long-term growth from the website.",
  "",
  "Recommended Offer To Present",
  "Present Package 2 first.",
  "It gives the client visible improvements plus direct business value through bookings and enquiries.",
  "",
  "Suggested Payment Terms",
  "50 percent advance before starting work.",
  "50 percent after completion and final handover.",
  "",
  "Optional Upsells",
  "- Monthly website updates and maintenance",
  "- Seasonal banners and offer updates",
  "- New gallery uploads",
  "- Festival or event landing sections",
  "- Monthly SEO improvements",
  "",
  "How To Position This To The Client",
  "This is not just a website redesign.",
  "It is a customer-conversion tool that helps the cafe get more calls, more WhatsApp enquiries, more bookings, and more repeat customers.",
  "",
  "Call To Action",
  "To begin, approval of the package and advance payment are required.",
  "",
  "Approval Format",
  "Selected Package: ____________________",
  "Advance Amount: _____________________",
  "Approved By: ________________________",
  "Date: _______________________________",
  "",
  "Prepared For Sharing",
  "This proposal is ready to send to the client."
)

function Escape-PdfText([string]$text) {
  return $text.Replace('\', '\\').Replace('(', '\(').Replace(')', '\)')
}

$contentLines = New-Object System.Collections.Generic.List[string]
$contentLines.Add("BT")
$contentLines.Add("/F1 17 Tf")
$contentLines.Add("42 798 Td")
$first = $true

foreach ($line in $lines) {
  $safe = Escape-PdfText $line
  if ($first) {
    $contentLines.Add("($safe) Tj")
    $first = $false
  } else {
    $contentLines.Add("0 -16 Td")
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

[System.IO.File]::WriteAllBytes((Join-Path $PSScriptRoot "cafooze-sales-proposal.pdf"), $pdf.ToArray())
