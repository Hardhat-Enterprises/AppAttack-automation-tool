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

nmap_plugin.sh
This plugin runs a tool called Nmap (short for "Network Mapper"). Nmap is like a scanner for computers on a network - it tells you what computers are out there, what doors (called "ports") are open, and what services are running.

Think of it like walking down a street and checking every house to see:

    Which houses exist (what computers are on the network)

    Which doors are unlocked (what ports are open)

    What each house is used for (what service is running - web server, email, etc.)

This specific plugin:

    Takes a target computer's address (like 192.168.1.1)

    Optionally takes a specific door/port number to check (like port 80 for websites)

    Runs Nmap to scan that computer

    Sends the results to a separate tool that formats them neatly (in JSON)


-------------------------------------------------------------------------------------------------------------------

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
