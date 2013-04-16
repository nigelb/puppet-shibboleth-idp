
class shibboleth_idp::container::tomcat6::params (
	$config_base = $osfamily?{
                "RedHat" => "/etc/tomcat6"
        },
	$package_version = $tomcat::params::tomcat_version,
	$package_name = $tomcat::params::tomcat_package,
) inherits tomcat::params
{
	class{'shibboleth_idp::container::base':
		provider => "tomcat6",
	}

}

