# Winclude_Fix
Fixes sloppy Windows file paths with incorrect upper/lowercase. 

It is very tempting, given time constraints, to use the wrong case in Windows C++ projects - Visual C++, after all, lets you get away with it. When porting to Linux, you may be stuck with hundreds of such includes! It is tedious to change them individually. 

This script automates the process. It parses the CMake errors for bad includes, locates them on the Linux file system via case-insensitive search, and replaces the #includes with the correct path.
