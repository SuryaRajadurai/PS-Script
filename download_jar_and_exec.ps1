
Write-Host -f Green "=====//START SCRIPT//====="

#====================================//Define variable//==================="
#change the value of 2 variables below:
$source = 'https://github.com/PacktPublishing/Java-Programming-for-Beginners/blob/master/Chapter01/1.2/HelloWorld.java'

$destination = 'C:\IT\HelloWorld.java'

$java_portable_path = "C:\IT\jPortable_8_Update_341_online.paf"

function downloadPackage {

    
    
    Write-Host "=====//Check Destination file ...."
    if (-not (Test-Path -LiteralPath $destination)) {
    
        Write-host -f Green  "`nProcess download to $destination .....`n"
    }
    else {
         Write-host -f Yellow  "`n'$destination' file already existed!`n"
         Write-host -f Green  "`nProcess delete and download .....`n"
         Remove-Item $destination
         
    }
    try {
        add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

        Invoke-WebRequest -Uri $source -OutFile $destination 

        #$credential = Get-Credential #Use this if need authentication
        #Invoke-WebRequest -Uri $source -OutFile $destination -Credential $credential
    }
    catch {
        Write-Error -Message "Unable to DOWNLOAD. Error was: $_" -ErrorAction stop
        break
    }
}
function extractPackage {
    
    Write-host -f Green  "=====//Process running by java portable`n"
    
    $arguments = "start java_portable_path -jar $destination"
    
   Start-Process powershell -Verb runAs -ArgumentList $arguments
}
 
 $DiskObjects = Get-WmiObject win32_logicaldisk -Filter "Drivetype=3"

 foreach ($disk in $DiskObjects)
 {
    $Name           = $disk.DeviceID
    $Capacity       = [math]::Round($disk.Size / 1073741824, 2)
    $FreeSpace      = [math]::Round($disk.FreeSpace / 1073741824, 2)
    $FreePercentage = [math]::Round($disk.FreeSpace / $disk.size * 100, 1)
    if ($Name -eq "C:") {

        
        Write-Host "Name: $Name"
        Write-Host "Capacity (GB): $Capacity"
        Write-Host "FreeSpace (GB): $FreeSpace"
        Write-Host "FreePercentage (%): $FreePercentage"

        if ($FreeSpace -gt 5) {
            Write-Host -f Green "==> Disk C:\ is normal"
        }
        else {
            Write-Host -f Yellow "==> Disk C:\ is not enough space"
        }
    }
    else {
        if ($Name -eq "D:") {
  
            Write-Host "Name: $Name"
            Write-Host "Capacity (GB): $Capacity"
            Write-Host "FreeSpace (GB): $FreeSpace"
            Write-Host "FreePercentage (%): $FreePercentage"
            if ($FreeSpace -gt 5) {
                Write-Host -f Green "==> Disk D:\ is normal"
                
                #Call function download package
                downloadPackage

                #Call function Extract package
                extractPackage

            }
            else {
                Write-Host -f Yellow "==> Disk D:\ is not enough space"
            }
        }

    }
 }
 
 Write-Host -f Green "=====//DONE SCRIPT//====="