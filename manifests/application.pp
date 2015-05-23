define wonder::application ($appname = $title, $binaryRelativePath = "${title}.woa", $username = $wonder::username) {
	exec { "add application ${appname}":
		require => Exec['wait for monitor'],
		command => "/usr/bin/curl -X POST -d \"{id: '${appname}',type: 'MApplication', name: '${appname}', unixOutputPath: '/home/${username}/logs', unixPath: '/home/${username}/apps/${binaryRelativePath}', autoRecover: false}\" http://localhost:1086/cgi-bin/WebObjects/JavaMonitor.woa/ra/mApplications.json"
	}

	exec { "add application instance 1 ${appname}":
		require => Exec["add application ${appname}"],
		command => "/usr/bin/curl -X GET http://localhost:1086/cgi-bin/WebObjects/JavaMonitor.woa/ra/mApplications/${appname}/addInstance&host=localhost"
	}

	exec { "add application instance 2 ${appname}":
		require => Exec["add application ${appname}"],
		command => "/usr/bin/curl -X GET http://localhost:1086/cgi-bin/WebObjects/JavaMonitor.woa/ra/mApplications/${appname}/addInstance&host=localhost"
	}

	exec { "schedule application instance ${appname}":
		require => [Exec["add application instance 1 ${appname}"], Exec["add application instance 2 ${appname}"]],
		command => "/usr/bin/curl -X GET \"http://localhost:1086/cgi-bin/WebObjects/JavaMonitor.woa/admin/turnScheduledOn?type=ins&name=${appname}-1\""
	}
}
