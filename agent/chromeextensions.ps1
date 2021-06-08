$xml=$null

if ((test-path 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe') -or (test-path 'C:\Program Files\Google\Chrome\Application\chrome.exe'))
{

    $userdir = dir 'c:\users\'

    ForEach ($user in $userdir){
        $user_name = $user.name
                if(Test-Path "C:\Users\$user_name\AppData\Local\Google\Chrome\User Data\local state")
                {
                  #Determine the last active user profile folder
                  $LocalState = get-content "C:\Users\$user_name\AppData\Local\Google\Chrome\User Data\Local State" | convertFrom-Json
                  $profileFolder = $LocalState.profile.last_active_profiles
                  #Set Profile Folder to Default in case Local state couldn't be read.
                  If ("$profileFolder" -like "$null")
                  {$ProfileFolder = 'Default'}
                   #Determine if Extensions have been added to avoid an error
                  if(Test-Path "C:\Users\$user_name\AppData\Local\Google\Chrome\User Data\$ProfileFolder\Extensions")
                  {

                    $extension_folders = Get-ChildItem -Path "C:\Users\$user_name\AppData\Local\Google\Chrome\User Data\$profileFolder\Local Extension Settings"

                    # get extension id from "Local Extension Settings" to avoid default chrome extensions
                    # then use it to retrieve infos from "Extensions" folder

                    foreach ($extension_folder in $extension_folders ) {
                      $appid = $extension_folder.BaseName

                      if(Test-Path "C:\Users\$user_name\AppData\Local\Google\Chrome\User Data\$profileFolder\Extensions"){
                        $version_folders = Get-ChildItem -Path "C:\Users\$user_name\AppData\Local\Google\Chrome\User Data\$profileFolder\Extensions\$appid"

                        foreach ($version_folder in $version_folders) {
                          $name = ""

                          if( (Test-Path -Path "$($version_folder.FullName)\manifest.json") ) {

                            try {
                                $json = Get-Content -Raw -Path "$($version_folder.FullName)\manifest.json" | ConvertFrom-Json
                                $name = $json.name

                            } catch {
                                #$_
                                $name = ""
                            }

                          }

                          if( $name -like "*MSG*" ) {

                            if( Test-Path -Path "$($version_folder.FullName)\_locales\en\messages.json" ) {

                                try { 
                                    $json = Get-Content -Raw -Path "$($version_folder.FullName)\_locales\en\messages.json" | ConvertFrom-Json
                                    $name = $json.appName.message

                                    if(!$name) {
                                        $name = $json.extName.message

                                    }

                                    if(!$name) {
                                        $name = $json.extensionName.message

                                    }

                                    if(!$name) {
                                        $name = $json.app_name.message

                                    }

                                    if(!$name) {
                                        $name = $json.application_title.message

                                    }

                                } catch { 
                                    $name = ""

                                }

                            }

                            ##: Sometimes the folder is en_US
                            if( Test-Path -Path "$($version_folder.FullName)\_locales\en_US\messages.json" ) {

                                try {
                                    $json = Get-Content -Raw -Path "$($version_folder.FullName)\_locales\en_US\messages.json" | ConvertFrom-Json
                                    $name = $json.appName.message

                                    if(!$name) {
                                        $name = $json.extName.message

                                    }

                                    if(!$name) {
                                        $name = $json.extensionName.message

                                    }

                                    if(!$name) {
                                        $name = $json.app_name.message

                                    }

                                    if(!$name) {
                                        $name = $json.application_title.message

                                    }

                                } catch {
                                    #$_
                                    $name = ""

                                }

                            }

                          }

                        }

                        ##: If we can't get a name from the extension use the app id instead
                        if( !$name ) {
                          $name = "[$($appid)]"

                        }

                        $browser_name = "Chrome"
                        $xml += "<BROWSEREXTENSIONS>"
                        $xml += "<USERNAME>$user_name</USERNAME>"
                        $xml += "<BROWSERNAME>$browser_name</BROWSERNAME>"
                        $xml += "<EXTENSIONNAME>$name</EXTENSIONNAME>"
                        $xml += "<EXTENSIONVERSION>$version_folder</EXTENSIONVERSION>"
                        $xml += "<EXTENSIONID>$appid</EXTENSIONID>"
                        $xml += "</BROWSEREXTENSIONS>"

                      }

                    }   

                  }

                }

    } 
}    
  else {

    $xml += "<BROWSEREXTENSIONS />"

  }

#[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)
        