$xml=$null
if ((test-path 'C:\Program Files (x86)\Mozilla Firefox\firefox.exe') -or (test-path 'C:\Program Files\Mozilla Firefox\firefox.exe'))
{ 
$parentdir = "C:\Users\"
$users = Get-ChildItem $parentdir
$ObjCollection = @()

Foreach($user in $users){
  $targetdir = ""
  $ffdir = $parentdir + $user.ToString() + "\AppData\Roaming\Mozilla\Firefox\Profiles" 
  $ejsons = if (test-path $ffdir) {Get-ChildItem -path $ffdir -File  -Filter "extensions.json" -Recurse}
  foreach ($ejson in $ejsons) {
    
    $targetdir = $ejson.directoryname

    $lines = $null 
    if (test-path "$targetdir\compatibility.ini") {$lines=Get-Content "$targetdir\compatibility.ini"}
    foreach ($l in $lines) {
        if ($l -like "lastVersion*"){
            $ls1 = $l.split("=")
            $ls2 = $ls1[1].split("_")
            $ffversion = $ls2[0]
        }
    }

    if (test-path "$targetdir\extensions.json") {
       $prefs = Get-Content "$targetdir\extensions.json"  | ConvertFrom-Json  # Read Prefernces JSON file
       $prefs =  $prefs.addons
     
       Foreach($pref in $prefs){
 
            $obj = New-Object System.Object
            $Permissions = ""  # force permissions variable to string

            $name = $pref.defaultlocale.name
            $version = $pref.version
            $description = $pref.defaultlocale.description
            $active = $pref.active
            $visible = $pref.visible
            $appdisabled = $pref.appdisabled
            $userdisabled = $pref.userdisabled
            $hidden = $pref.hidden
            $location = $pref.location
            $id = $pref.id
            $sourceURI = $pref.sourceURI

            $Ptemp = $pref.userpermissions.permissions
            foreach ($pt in $Ptemp) {$Permissions = $Permissions + $pt.tostring() + "._."} 

            $obj | Add-Member -MemberType NoteProperty -Name Name -Value $name
            $obj | Add-Member -MemberType NoteProperty -Name Version -Value $version
            $obj | Add-Member -MemberType NoteProperty -Name Description -Value $description
            $obj | Add-Member -MemberType NoteProperty -Name Permissions -Value $Permissions
            $obj | Add-Member -MemberType NoteProperty -Name ID -Value $id
            $obj | Add-Member -MemberType NoteProperty -Name Active -Value $active
            $obj | Add-Member -MemberType NoteProperty -Name visible -Value $visible
            $obj | Add-Member -MemberType NoteProperty -Name appdisabled -Value $appdisabled
            $obj | Add-Member -MemberType NoteProperty -Name userdisabled -Value $userdisabled
            $obj | Add-Member -MemberType NoteProperty -Name hidden -Value $hidden
            $obj | Add-Member -MemberType NoteProperty -Name location -Value $location
            $obj | Add-Member -MemberType NoteProperty -Name sourceURI -Value $sourceURI


            $obj | Add-Member -MemberType NoteProperty -Name User -Value $user
            $obj | Add-Member -MemberType NoteProperty -Name FireFoxVer -Value $ffversion
            $obj | Add-Member -MemberType NoteProperty -Name LastScan -Value $(Get-Date)
                
         # ignore default extensions    
         if($location -ne "app-builtin" -and $location -ne "app-system-defaults"){ 
           $user_name=$user.name
           $browser_name="Firefox"
           $ext_name=$obj.name
           $version_folder=$obj.version
           $appid=$obj.id
                $xml += "<BROWSEREXTENSIONS>"      
                $xml += "<USERNAME>$user_name</USERNAME>"
                $xml += "<BROWSERNAME>$browser_name</BROWSERNAME>"
                $xml += "<EXTENSIONNAME>$ext_name</EXTENSIONNAME>"
                $xml += "<EXTENSIONVERSION>$version_folder</EXTENSIONVERSION>"
                $xml += "<EXTENSIONID>$appid</EXTENSIONID>"
                $xml += "</BROWSEREXTENSIONS>"

           }
         else{
              Continue
             }
       } 
      
                
     } 
   } 
 } 
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 
    [Console]::WriteLine($xml)
}