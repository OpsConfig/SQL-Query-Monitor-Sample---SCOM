Param($DatabaseName, $Threshold, $Instance, $Port, $ErrorLogging)
 
$api = new-object -comObject "MOM.ScriptAPI"
$bag =$api.CreatePropertyBag()

 
#$DatabaseName = "OperationsManager"
#$Threshold = 10
#$Instance= "MSSQLSERVER"
#$Port= "1433"
#$ErrorLogging="True"
 
$ServerName=$env:COMPUTERNAME
 
$DatabaseQuery = @"
USE $DatabaseName
SELECT COUNT(*) AS Records FROM AlertView
"@
 
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source=$ServerName\$Instance,$Port;Database=$DatabaseName;Integrated Security=True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $DatabaseQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) | Out-Null
$SqlConnection.Close()
 
$TableCount =$DataSet.Tables[0]
 
[int]$Count = $TableCount | Select -ExpandProperty "Records"
 
If ($Count -ge $Threshold) {
$bag.AddValue("Status","TableCountExceeded")
$bag.AddValue("Count",[int]$Count)
$bag.AddValue("Instance",$DatabaseName)
$bag.AddValue("DatabaseName",$Instance)
$bag.AddValue("Threshold",$Threshold)
 
 
} else {
 
If ($Count -lt $Threshold) {
 
 
$bag.AddValue("Status","TableCountNotExceeded")
$bag.AddValue("Count",[int]$Count)
$bag.AddValue("Instance",$DatabaseName)
$bag.AddValue("DatabaseName",$Instance)
$bag.AddValue("Threshold",$Threshold)
}
}
 
$version = $PSVersionTable.PSVersion | Select -ExpandProperty "Major"
$Bit32 = [IntPtr]::size -eq 4
$Bit64 = [IntPtr]::size -eq 8
 
 
If ($ErrorLogging -eq 1){$api.LogScriptEvent("Custom T-SQL Monitor",9999,2,"[PowerShell Version: $version]  [32 Bit:$Bit32] [64 Bit:$Bit64] [The following errors occurred during script execution:] [$error]")}


 
$bag
 




