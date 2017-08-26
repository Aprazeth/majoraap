# Table of Contents

- [Table of Contents](#table-of-contents)
  - [Description](#description)
    - [Quick listing of my scripts](#quick-listing-of-my-scripts)
      - [Settings, extensions I use(d) and recommend](#settings-extensions-i-use-d-and-recommend)
    - [Why the name **majoraap**](#why-the-name-majoraap)

## Description

A repository of my tools and scripts. This is where I will be storing my PowerShell scripts that I have created in my own free time, and make available for use (please feel free to refer to the license)

## Quick listing of my scripts

The actual scripts can be found in the folder '.\Scripts'

- **Set-Unblock.ps1** - a PowerShell script to automatically unblock downloaded files from your intranet/internet.
- **Backup-EverNoteDatabase.ps1** - a PowerShell script that allows you to make a backup of your EverNote database, and starts your cloud-storage provider (such as DropBox, OwnCloud, Box.net etc.) after having created the EverNote backup. It can be run via the Task Scheduler to make regular and automatic backups.
- **Get-ARMAFileContent.PS1** - a PowerShell script that traverses the folder and subfolders for all ARMA ItemList files and extracts the class, quality, and price information into a CSV-file. This script is still in progress/being worked on.

### Settings, extensions I use(d) and recommend

Settings, extensions, and other tidbits I highly recommend:

- Visual Studio Code
  - Icons: Material Icon theme
  - Theme: Monokai
  - Font: Fira Code font (including the recommended setting to enable font ligatures)
  - Extensions
    - CodeRunner
    - DevSkim
    - Excel Viewer
    - Git History (git log)
    - Git Indicators
    - gitignore
    - HTML Snippets
    - Markdown Preview Github Styling
    - markdownlint
    - Markdown All in One
    - mssql
    - Output Colorizer
    - PowerShell
    - Start any shell
    - Terminal Tabs
    - TODO Highlight
    - Visual Studio Code Format
    - XML Tools

- Pester
- ScriptAnalyzer

I have created a generic Pester file, called **Generic.Tests.ps1** - which will run a few checks and test on all the **PS1** (PowerShell scripts) and **PSM1** (PowerShell Modules) files, namely:

- Inclusion of a commentblock containing:
  - Synopsis
  - Description
  - At least one Example
- Complete check of ScriptAnalyzer
  - Errors
  - Warnings
  - Informational

All checks for ScriptAnalyzer should return '**0**'; anything higher I'll consider a failed test. All checks for the commentblock should of course be at least 1 or higher (in the case of 'Example')

## Why the name **majoraap**

I had a website for several years with that name. It was where I started with a few posts on this very topic (scripts); I figured that a proper way to distribute them - and make them available to everyone - was to use Github. The website has since been taken offline, yet I continue to work on my scripts here.