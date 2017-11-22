Function Test-TcpPort 
{
    [cmdletbinding()]
    param (
        $ip,
        $port
    )

    $socket = new-object System.Net.Sockets.TcpClient($ip, $port)
    If($socket.Connected)
    {
        $socket.Close()
        return $true
    } else {
        return $false
    }
}