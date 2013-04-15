
class shibboleth-idp
{
	require java
	require tomcat
	require shibboleth-idp::params

	file { "/opt/shib_idp":
		ensure => "directory",
		alias => "ShibIDPWD"
	}

	file{ "/opt/shibidp/shibboleth-identityprovider-${shibboleth-idp::params::version}.zip":
		ensure => present,
		source => "http://shibboleth.net/downloads/identity-provider/${shibboleth-idp::params::version}/shibboleth-identityprovider-${shibboleth-idp::params::version}-bin.zip",
		alias => "ShibSource",
		require => [File['ShibIDPWD']]
	} 

	exec { "unzip idp":
		command => "unzip ",
		cwd => "",
		require => [File['ShibSource']]
	}

	
}
