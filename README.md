# New Fortigate Configuration tool

This is an easy to read / adjust Fortigate configuration script made in Powershell.
<br/>Place the files somewhere on your desktop in a folder (e.g.: \Documents\FGT\ *)
<br/>
<br/>Run .\FGT_Start.ps1 
<br/>
It first checks if Posh-SSH is installed, if not, it will try to install it for you. 
Due too this reason, the first connection takes a little time. <br/>Once it is installed on your pc, the next connection will be fast.  
<br/>
Follow the steps 1-7 for the best experience (it will remember some stuff like wan interface you have chosen before etc)<br/>
Or pick indiviual options from the menu shown, for a specific configuration. <br/>
<br/>
It has been tested with Fortigate 5.2.x and 6.2.x, it seems to work on both versions, however use at your own risk 
<br/> Always make a backup just in case!<br/>
<br/>
Some pictures:
<br/><br/>
![Alt text](/Pictures/FGT_Connect.png?raw=true "Connecting_FGT_Unit") <br/>
![Alt text](/Pictures/FGT_Menu_Options.png?raw=true "FGT_Menu") <br/>
![Alt text](/Pictures/FGT_Lan.png?raw=true "FGT_Lan_MOD") <br/>
![Alt text](/Pictures/FGT_Policy.png?raw=true "FGT_Pol_MOD") <br/>
![Alt text](/Pictures/FGT_Gui_Int.png?raw=true "FGT_GUI_interface") <br/>
![Alt text](/Pictures/FGT_Gui_Policy.png?raw=true "FGT_GUI_Policy") <br/>
