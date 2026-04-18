This Read Me gives you a better understanding of what each file in the parsers folder does:
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

1. john_parser.py
      - This file is a parser, a helper that takes messy output from a tool and cleans it up so it's ready to be sent to an AI for analysis. Specifically, this parser works with 
        John the Ripper (a password cracking tool). John the Ripper tries to guess passwords by testing millions of possibilities. Its output can be very messy with lots of 
        extra lines you don't care about.

      - What this parser does:
            a.) Takes the raw output from John the Ripper.
            b.) Cleans it up by removing useless lines (like file names, summary text, empty lines).
            c.) Creates a question asking an AI to:
                    - Find the cracked password in the output.
                    - Explain why that password is weak.
                    - Give advice on making better passwords.

     - Think of it like a personal assistant who reads through a messy report, pulls out only the important information, and then writes a question to an expert asking them to          explain what it means in plain English.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2. nikito_parser.py
     - This file is a parser for Nikto, a tool that scans websites for security problems. Nikto is like a security guard who walks around a website checking for unlocked doors,         weak spots, and things that are set up wrong.

     - What this parser does:
          a.) Takes the messy output from a Nikto scan.
          b.) Finds the important parts, specifically, lines that start with + (these are the findings/problems).
          c.) Figures out which website/server was scanned (the "host" or IP address).
          d.) Creates a question asking an AI to explain all the findings in plain, beginner-friendly English.

    - Think of it like a translator who takes a technical security report full of jargon and turns it into a simple conversation: "Here's what the scan found on your website...
      here's what each problem means... and here's how to fix it."

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3. nmap_parser.py
    - This file is a parser for Nmap, a tool that scans computers on a network to see what "doors" (called ports) are open. 

    - What this parser does:
        a.) Takes the messy output from an Nmap scan.
        b.) Finds the computer that was scanned (IP address or hostname).
        c.) Finds all the open doors (ports) and what service is running behind each one.
        d.) Creates a question asking an AI to explain in plain English what these open ports mean and how to stay safe.

    - Think of it like a security translator that takes a technical network report (full of jargon like "port 22/tcp open ssh") and turns it into a simple conversation: "Hey,
      your computer has door #22 open, and behind it is a service called SSH. Here's what that means and whether you should worry about it."

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


sqlmap_parser.py
This file is a parser for SQLMap - a tool that tries to hack into websites by tricking their databases. SQLMap is like a digital lock picker that tests whether a website's database has a dangerous weakness called "SQL injection."

What is SQL injection?
Imagine a website has a login form that asks for your username. A hacker might type something sneaky like ' OR '1'='1 instead of a real name. If the website is poorly built, that sneaky text can trick the database into giving away all its secrets (passwords, credit cards, etc.).

What this parser does:

    Takes the messy output from an SQLMap scan

    Finds the website that was tested (the target URL)

    Extracts all the important messages (INFO, WARNING, CRITICAL, PAYLOAD)

    Removes duplicate messages (so you don't see the same thing twice)

    Creates a question asking an AI to explain what the findings mean in plain English

Think of it like a detective's assistant who reads through a messy investigation report, highlights the important clues, removes the duplicates, and then asks an expert to explain what those clues mean to someone who isn't a detective.


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


wapiti_parser.py
This file is a parser for Wapiti - a tool that scans websites for security problems by acting like a hacker. Wapiti is like a digital burglar who tries to break into a website by testing all the ways a real hacker might attack.

What makes Wapiti different?
Unlike other scanners that just look for obvious problems, Wapiti actually tries to exploit (take advantage of) weaknesses to see if they're real. It tests for things like:

    XSS (Cross-Site Scripting) - Can a hacker inject bad code into your website?

    SQL Injection - Can a hacker trick your database?

    File inclusion - Can a hacker force your website to show secret files?

What this parser does:

    Takes the messy output from a Wapiti scan

    Finds the website that was scanned (the target URL)

    Finds each type of vulnerability tested (like "XSS vulnerabilities" or "SQL Injection vulnerabilities")

    Extracts the specific problems found under each type

    Creates a question asking an AI to explain what the vulnerabilities mean and how to fix them

Think of it like a medical report translator - Wapiti is like a full body scan that finds "here's a problem with your heart, here's a problem with your lungs," and this parser organizes those findings and asks a doctor (the AI) to explain them in plain English.



