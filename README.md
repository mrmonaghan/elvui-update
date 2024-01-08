# elvui-update

A simple `Powershell` script to automate the installation and updating of the ElvUI World Of Warcraft addon, as it's not currently available for management via CurseForge.

# Running

This script required your system's `ExecutionPolicy` allow for the execution of unsigned scripts. This can be achieved in one of two ways:

## System-Wide

As Administrator, open a `Powershell` terminal and run the following command:

```Set-ExecutionPolicy -ExecutionPolicy Restricted```

This will allow the OS to execute any `Powershell` script files, and is considered insecure. However, this will allow the update script to be run directly from the context menu by right-clicking on the `elvui-update.ps1` file and selecting `Run with Powershell`.

## Per-Execution

Alternatively, you can set `ExecutionPolicy` each time the script is invoked. Open an unelevated `Powershell` terminal and run the following command:

`powershell.exe -noprofile -executionpolicy bypass -file <path-to-script>.ps1`

This will bypass the system's `ExecutionPolicy` without the need for administrative privledges, however this command will need to be run each time the script is invoked as execution from the `Run With Powershell` context menu option will be blocked.
