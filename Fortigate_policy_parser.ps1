#PART 0 - INITIATING
Param(
[parameter(Mandatory=$true)]$in,
[string]$out
)

IF($in -match '^(\.\\)') { $in = $in -replace "^(\.\\)" }
IF($out -eq ""){ $out = $in -replace "(\.[a-z]*)$",".csv" }

$location = Get-Location 
$in_file = "$location\$in"
$temp_file = "$location\temp.txt"
$out_file = "$location\$out"
$array = @()
[int]$rule = 0


#PART 1 - CREATING A TEMPORARLY WORK FILE 
    $conf_file = Get-Content $in_file

    [string]$conf_file = $conf_file -replace "\s{2,}"
    [string]$conf_file = $conf_file -replace "next","`r`n"
    [string]$conf_file = $conf_file -replace "config firewall policy","config firewall policy `r`n"

    add-content $temp_file $conf_file

#PART 2 - PARSING & CSV CREATING.
$conf_policy = Get-Content $temp_file

foreach ($line in $conf_policy) {

        IF($line -match '^ edit (?<ID>[\d]*)( set name "(?<NAME>.*)")? set uuid (?<UUID>.*) set srcintf "(?<SRCINTF>.*)" set dstintf "(?<DSTINTF>.*)" set srcaddr (?<SRCADDR>"(.*?)") set dstaddr (?<DSTADDR>"(.*?)")( set action (?<ACTION>accept))? set schedule "(?<SCHEDULE>.*)" set service (?<SERVICE>"(.*?)")( set logtraffic (?<LOG>all|disable))?(( set ippool (?<IPPOOL>enable)) set poolname "(?<POOLNAME>.*)")?( set fsso (?<FSSO>disable))?( set nat (?<NAT>enable))?( set comments "(?<COMMENTS>.*)")?')
        {
  
            $array += [PSCustomObject] @{ID = $Matches.ID
                                         NAME = $Matches.NAME
                                         UUID = $Matches.UUID
                                         SRCINTF = $Matches.SRCINTF
                                         DSTINTF = $Matches.DSTINTF
                                         SRCADDR = $Matches.SRCADDR
                                         DSTADDR = $Matches.DSTADDR
                                         ACTION = $Matches.ACTION
                                         SCHEDULE = $Matches.SCHEDULE
                                         SERVICE = $Matches.SERVICE
                                         LOG = $Matches.LOG
                                         IPPOOL = $Matches.IPPOOL
                                         POOLNAME = $Matches.POOLNAME
                                         FSSO = $Matches.FSSO
                                         NAT = $Matches.NAT
                                         COMMENTS = $Matches.COMMENTS
                                        }
        $rule += 1
        }
}

write-host "--- DEBUG INFORMATION ---"
write-host "File source : $in"              #Debug
write-host "Path : $in_file"                 #Debug
write-host "File output : $out"        #Debug
write-host "Parsing rules : $rule"             #Debug
Write-host "---------- END ----------"

Remove-Item $temp_file                          #Suppression du fichier temp
$array | export-csv $out_file                   #Export du tableau en CSV
