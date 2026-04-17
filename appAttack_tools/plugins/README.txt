This Read Me gives you a better understanding of what each file in the plugins folder does:
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

1. automated_reporting_plugin.sh
    - When the "Penetration Testing Team" runs security scans using the AppAttack toolkit. Each scan result gets saved in a different text file, scattered around your computer,        which can be confusing and time-consuming because now you need to compile all those results into a single, readable report to show your team or keep for your records.

    - This plugin automates that process. It:
        a.) Finds all scan result files (any file ending with _plugin_scan.txt or named code_review_report.txt).
        b.) Creates a HTML file that contains all those scan results in one place.
        c.) Saves the webpage with a timestamp in the filename (e.g., scan_report_20260116_143022.html).
        d.) Organizes the report with headings so you can easily see which results came from which scan.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2. nmap_plugin.sh
    - This plugin runs a tool called Nmap (short for "Network Mapper"). Nmap is like a scanner for computers on a network, it tells you what computers are out there, what doors        (called "ports") are open, and what services are running.

    - This specific plugin:
      a.) Takes a target computer's address (like 192.168.1.1).
      b.) Optionally takes a specific door/port number to check (like port 80 for websites).
      c.) Runs Nmap to scan that computer.
      d.) Sends the results to a separate tool that formats them neatly (in JSON)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sample_plugin.sh
This file is a blank template or starter kit for creating new plugins.

Think of it like an empty coloring book page that has the outlines already drawn. You don't need to start from scratch - just fill in the blanks with your own colors (code).

This template shows you:

    What every plugin needs to have (the required parts)

    Where to put your own code

    How to name your plugin

If you want to add a new security tool to AppAttack, you copy this file, rename it, and then fill in the empty space with your tool's specific commands.



-----------------------------------------------------------------------------------------------------------------------------

secure_code_review_plugin.sh
This plugin checks your code for security problems - like having a detective read through your code to find weak spots.

Think of it like three different safety inspectors looking at the same building:

    Bandit - Checks Python code for security issues (like finding unlocked doors)

    Brakeman - Checks Ruby on Rails code for problems (like finding weak windows)

    Snyk - Checks for known security holes in the outside libraries your code uses (like making sure your locks aren't a brand that burglars know how to pick)

What this plugin actually does:

    Asks you for the folder where your code lives

    Runs all three security checkers on that folder

    Collects all their findings into ONE report file

    Saves that report on your computer so you can read it later
