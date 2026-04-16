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


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


nikito_parser.py




