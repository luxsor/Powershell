
function Invoke-HttpServer{
 param(
        [string]$uri = 'http://192.168.100.5:8000/',
        [string]$aclUsername
    )

  
    if ( -not [string]::IsNullOrWhiteSpace($username))
    {
              # Comando netsh per aggiungere l'ACL
            $netshCommand = "netsh http add urlacl url=$uri user=$aclUsername"

            # Esegui il comando netsh
            try {
                Invoke-Expression $netshCommand
                Write-Host -ForegroundColor Green "Operazione eseguita con successo per l'URL $uri e l'utente $aclUsername."
                

            } catch {
                Write-Error "Errore nell'aggiungere l'ACL: $_" -ErrorAction Stop
                 

            }
    
    }


# Crea un nuovo oggetto HttpListener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($uri)
$listener.Start()
Write-Host "Server HTTP in ascolto su $uri"

try {
    while ($listener.IsListening) {
        # Attendi la richiesta del client
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
           
        # Estrai il percorso dal URL della richiesta
        $requestedPath = $request.Url.AbsolutePath.Substring(1)
        $location = Get-Location
      
        # Log della richiesta
        Write-Host "> Richiesta ricevuta: $($request.Url)"

        # Percorso per il download di file
        $file = [System.IO.Path]::Combine($location, $requestedPath)

        if (Test-Path $file) {

            # Invia il file come risposta
            try {
                $buffer = [System.IO.File]::ReadAllBytes($file)
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                
                Write-Host -ForegroundColor Green ">> $file scaricato"

            }
            catch {
                # Errore nella lettura del file
                $response.StatusCode = 500
                Write-Host "Errore durante la lettura del file: $_"
            }

        } else {
            # File non trovato
            $response.StatusCode = 404
            Write-Host -ForegroundColor Yellow "> File non trovato: $file"
            
        }
      
        # Chiudi la risposta
       $response.Close()

    }
}
finally {

    # Ferma il listener quando lo script termina
    if ($listener.IsListening -ne $false ){
    $listener.Stop()
    }
        
}


}

