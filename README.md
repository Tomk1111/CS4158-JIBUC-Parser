# JIBUC Parser

## Author
__Thomas Kiely__ - 1718203
## Overview
This project was developed in Visual Studio Code on a WSL Ubuntu-18.04 system. This is a tool used to report on the correctness of a program with respect to its structure for the syntactically limited language __JIBUC__. This has been developed as part of the module `CS4158 - Programming Language Technology`.


## How to Run
Extract the zipped project folder. On a linux system, navigate to the extracted folder through the terminal. The included `runner.sh` script automates the process of compiling and building the parser with Flex & Bison. To execute this script use the following command.

```bash
    ./runner.sh
```
This will build the parser file which is used to parse the language instances. Once this file, `Parser` has been generated, it can be used to test the input text against the grammar. There are two potential use cases for this file

### User Input
To test the parser using user input text directly from the terminal, execute the following command:

```bash
    ./Parser
```

### File Input
To test the parser using text already defined in a text file, execute the following command:

```bash
    ./Parser < [PATH_TO_TEXT_FILE]
```
--------
**NOTE:**

This file input is required to be formatted for unix systems and to not contain special Windows characters. Ubuntu provides a utility for converting existing text files with these special characters to Unix format. To convert these files using Ubuntu, execute the following. 
```bash
    dos2unix [PATH_TO_TEXT_FILE]
```
--------

