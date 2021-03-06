# PowerShell Fortigate Configuration tool

This is an easy to read / adjust Fortigate configuration script made in Powershell.
<br/>Place the files wherever you want (usb, local pc, other partition,...).
<br/>Unblock the file if needed (right click > properties > unblock file)
<br/>
<br/>Run: <br/>

<pre> <span>.\FGT_Start.ps1 </span> </pre>

<br/>
In case you get an error that scripts cannot run on your system <br />
Type: Set-ExecutionPolicy -RemoteSigned 
<br/>You can set it back to restricted later, if you want too (Set-ExecutionPolicy Default).
<br/><br/>
It first checks if Posh-SSH is installed, if not, it will try to install it for you. 
Due too this reason, the first connection takes a little time. <br/>Once it is installed on your pc, the next connection will be fast.  
<br/>
Follow the steps 1-7 for the best experience.<br/>
Or pick indiviual options from the menu shown, for a specific configuration. <br/></br>
In case you are wondering, when applying the policy's, it will only add policy's not delete existing policy's.
However in case they have the same ID (default 1-10) It will overwrite them. 
In that case you can edit the policy numbers to some range behind your current policy ID's.
<br/><br/>
It has been tested with Fortigate 5.2.x and 6.2.x, it seems to work on both versions, however use at your own risk. <br/>
<br/> Always make a backup just in case...<br/>
<br/> ! Bugs found on New FGT ! 

Seems something off with the lan configuration (lan vs internal mec. check needed)

<br/></br>
Some pictures:
<br/><br/>

![alt text](/Pictures/FGT_Connect.png?raw=true "Connecting_FGT_Unit") <br/>
![alt text](/Pictures/FGT_Menu_Options.png?raw=true "FGT_Menu") <br/>
![alt text](/Pictures/FGT_Lan.png?raw=true "FGT_Lan_MOD") <br/>
![alt text](/Pictures/FGT_Lan_NoABCNet.png?raw=true "FGT_Lan_NoABCNet") <br/>
![alt text](/Pictures/FGT_Policy.png?raw=true "FGT_Pol_MOD") <br/>
![alt text](/Pictures/FGT_Policy_NoABCNet.png?raw=true "FGT_Pol_NoABCNet") <br/>
![alt text](/Pictures/FGT_Gui_Int.png?raw=true "FGT_GUI_interface") <br/>
![alt text](/Pictures/FGT_Gui_Policy.png?raw=true "FGT_GUI_Policy") <br/>
