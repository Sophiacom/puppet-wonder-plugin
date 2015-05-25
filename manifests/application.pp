define wonder::application ($appname = $title, $binaryRelativePath = "${appname}.woa/${appname}", $username = $wonder::username) {
	exec { "add application ${title}":
		require => Exec['wait for monitor'],
		command => "/usr/bin/curl -X POST -d \"{id: '${title}',type: 'MApplication', name: '${title}', unixOutputPath: '/home/${username}/logs', unixPath: '/home/${username}/apps/${binaryRelativePath}', autoRecover: false}\" http://localhost:1086/cgi-bin/WebObjects/JavaMonitor.woa/ra/mApplications.json"
	}

	exec { "add application instance 1 ${title}":
		require => Exec["add application ${title}"],
		command => "/usr/bin/curl -X GET http://localhost:1086/cgi-bin/WebObjects/JavaMonitor.woa/ra/mApplications/${title}/addInstance&host=localhost"
	}

	exec { "add application instance 2 ${title}":
		require => Exec["add application ${title}"],
		command => "/usr/bin/curl -X GET http://localhost:1086/cgi-bin/WebObjects/JavaMonitor.woa/ra/mApplications/${title}/addInstance&host=localhost"
	}

	exec { "schedule application instance ${title}":
		require => [Exec["add application instance 1 ${title}"], Exec["add application instance 2 ${title}"]],
		command => "/usr/bin/curl -X GET \"http://localhost:1086/cgi-bin/WebObjects/JavaMonitor.woa/admin/turnScheduledOn?type=ins&name=${title}-1\""
	}

	if !defined(File['/var/lib/webobjects/htdocs/WebObjects']) {
		file { ['/var/lib/webobjects', '/var/lib/webobjects/htdocs', '/var/lib/webobjects/htdocs/WebObjects']:
			ensure => 'directory',
		}
	}

	if !defined(File["/var/lib/webobjects/htdocs/WebObjects/${appname}.woa"]) {
		file { "/var/lib/webobjects/htdocs/WebObjects/${appname}.woa":
			ensure	=> 'link',
			target	=> "/home/${username}/apps/${appname}.woa",
			require	=> File['/var/lib/webobjects/htdocs/WebObjects'],
		}
	}
}
