This Read Me gives you an understanding of what the plugins in this folder do:

------------------------------------------------------------------------------------------

automated_reporting_plugin.sh
- When the penetration testing team runs security scans using the AppAttack toolkit.  Each scan saved its results in a different text file, scattered around your computer. Now you need to compile all those results into a single, readable report to show your team or keep for your records.

This plugin automates that process. It:

    Finds all scan result files (any file ending with _plugin_scan.txt or named code_review_report.txt)

    Creates an HTML webpage that contains all those scan results in one place

    Saves the webpage with a timestamp in the filename (e.g., scan_report_20260116_143022.html)

    Organizes the report with headings so you can easily see which results came from which scan.


-------------------------------------------------------------------------------------------------------------------

