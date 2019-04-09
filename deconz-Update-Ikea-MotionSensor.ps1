$IKEAdurationTimeout = 30
$secret = "TOPsecretKEY"
$uri = "http://youradresstodeconz:8080/api/$secret/"
$lights = (Invoke-WebRequest -Uri "$($uri)lights").content | ConvertFrom-Json | sort
$sensors = (Invoke-WebRequest -Uri "$($uri)sensors").content | ConvertFrom-Json | sort


foreach($obj in $sensors.psobject.properties){
	$sensorobj = $sensors.$($obj.Name)
	if($sensorobj.name -match "DFRI motion sensor"){
		$sensorobj
		$sensorobjuri = "$($uri)sensors/$($sensorobj.uniqueid)"
		Write-Host $sensorobjuri
		$sensorobjInfo = (Invoke-WebRequest -Uri $sensorobjuri).content | ConvertFrom-Json | sort
		if($sensorobjInfo.config.duration -ne $IKEAdurationTimeout){
			Write-Host "Sensor time set to $($sensorobjInfo.config.duration), not $IKEAdurationTimeout"
			$sensorupdateobjuri = "$($uri)sensors/$($sensorobj.uniqueid)/config"
			Write-Host $sensorupdateobjuri
			$json = "" | select "duration"
			$json.duration = $IKEAdurationTimeout
			$json = $json | ConvertTo-Json -Depth 100
			Invoke-RestMethod -Method Put -Uri $sensorupdateobjuri -Body $json -ContentType 'application/json'
		}
		else{
			Write-Host "Sensor time set to $($sensorobjInfo.config.duration) - OK"
		}
	}
}
