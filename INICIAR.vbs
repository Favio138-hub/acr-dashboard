' Doble clic aqui si iniciar.bat no abre ventana
Set sh = CreateObject("WScript.Shell")
folder = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
cmd = "cmd /k cd /d """ & folder & """ && INICIAR.cmd"
sh.Run cmd, 1, False
