john_parser.py
This file is a parser - a helper that takes messy output from a tool and cleans it up so it's ready to be sent to an AI for analysis.

Specifically, this parser works with John the Ripper (a password cracking tool). John the Ripper tries to guess passwords by testing millions of possibilities. Its output can be very messy with lots of extra lines you don't care about.

What this parser does:

    Takes the raw output from John the Ripper

    Cleans it up by removing useless lines (like file names, summary text, empty lines)

    Creates a question asking an AI to:

        Find the cracked password in the output

        Explain why that password is weak

        Give advice on making better passwords

Think of it like a personal assistant who reads through a messy report, pulls out only the important information, and then writes a question to an expert asking them to explain what it means in plain English.


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


nikito_parser.py
This file is a parser for Nikto - a tool that scans websites for security problems. Nikto is like a security guard who walks around a website checking for unlocked doors, weak spots, and things that are set up wrong.

What this parser does:

    Takes the messy output from a Nikto scan

    Finds the important parts - specifically, lines that start with + (these are the findings/problems)

    Figures out which website/server was scanned (the "host" or IP address)

    Creates a question asking an AI to explain all the findings in plain, beginner-friendly English

Think of it like a translator who takes a technical security report full of jargon and turns it into a simple conversation: "Here's what the scan found on your website... here's what each problem means... and here's how to fix it."

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


nmap_parser.py
This file is a parser for Nmap - a tool that scans computers on a network to see what "doors" (called ports) are open. Nmap is like a digital door checker that walks down a street and tries every door on every house to see which ones are unlocked.

What this parser does:

    Takes the messy output from an Nmap scan

    Finds the computer that was scanned (IP address or hostname)

    Finds all the open doors (ports) and what service is running behind each one

    Creates a question asking an AI to explain in plain English what these open ports mean and how to stay safe

Think of it like a security translator that takes a technical network report (full of jargon like "port 22/tcp open ssh") and turns it into a simple conversation: "Hey, your computer has door #22 open, and behind it is a service called SSH. Here's what that means and whether you should worry about it."


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------










