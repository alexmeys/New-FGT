# New Fortigate Configuration tool

This is an easy to read / adjust Fortigate configuration script made in Powershell.
Place the files somewhere on your desktop in a folder (e.g.: \Documents\FGT\*)

Run .\FGT_Start.ps1 

It first checks if Posh-SSH is installed, if not, it will try to install it for you. 
Due too this reason, the first connection takes a little time. Once it is installed on your pc, the next connection will be fast.  

Follow the steps 1-6, or pick indiviual options from the menu. 

It has been tested with Fortigate 5.2.x and 6.0.x, it seems to work on both versions, however use at your own risk (make a backup just in case).

Some pictures:

![Alt text](/Pictures/FGT_Connect.png?raw=true "Optional Title") <br/>
![Alt text](/Pictures/FGT_Menu_options.png?raw=true "Optional Title") <br/>
![Alt text](/Pictures/FGT_Lan.png?raw=true "Optional Title") <br/>
![Alt text](/Pictures/FGT_Policy.png?raw=true "Optional Title") <br/>
![Alt text](/Pictures/FGT_Gui_Int.png?raw=true "Optional Title") <br/>
![Alt text](/Pictures/FGT_Gui_Policy.png?raw=true "Optional Title") <br/>
