
class shibboleth_idp::container::tomcat6::config
{
	require shibboleth_idp::container::tomcat6::params

        package { 'tomcat':
                ensure => $shibboleth_idp::container::tomcat6::params::package_version,
                name   => $shibboleth_idp::container::tomcat6::params::package_name,
        }


        file{"${shibboleth_idp::container::tomcat6::params::config_base}/Catalina/localhost/shibboleth-idp.xml":
                alias   => "context-file",
                content => template("shibboleth_idp/shibboleth-idp.xml.erb"),
                owner   => $user,
                group   => $group

        }

	augeas { "shibboleth-endorsed-directory":
                lens    => "Shellvars_list.lns",
                incl    => "${shibboleth_idp::container::tomcat6::params::config_base}/tomcat6.conf",
                context => "/files/${shibboleth_idp::container::tomcat6::params::config_base}/tomcat6.conf",
                changes => [
			"set JAVA_OPTS[1]/value[3] -Djava.endorsed.dirs=${shibboleth_idp::params::shib_base}/lib/endorsed"
                ],
        }	
}

