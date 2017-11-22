Function Test-TcpPort 
{
    [cmdletbinding()]
    param (
        $ip,
        $port,
        $timeout=2000 # milliseconds
    )

    $ErrorActionPreference = "SilentlyContinue"
    $tcpClient = new-object System.Net.Sockets.TcpClient
    $iar = $tcpClient.BeginConnect($ip,$port,$null,$null)
    $wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)

    # Check to see if the connection is done
    if(-not $wait)
    {
        # Close the connection and report timeout
        $tcpclient.Close()
        Write-Verbose "Connection Timeout"
        Return $false
    }
    else
    {
        # Close the connection and report the error if there is one
        $error.Clear()
        $tcpclient.EndConnect($iar) | out-Null
        if(!$?){
            Write-Verbose $error[0]
            $failed = $true
            }
        $tcpclient.Close()
    }

    # Return $true if connection Establish else $False
    if($failed){return $false}else{return $true}

}