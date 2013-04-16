
class shibboleth_idp(
	$servlet_container = "tomcat6"
)
{
	require java
	require shibboleth_idp::params
	if !defined(Class["shibboleth_idp::container::base"])
	{
		class{"shibboleth_idp::container::${servlet_container}::params":
			before => File['idp-base-dir']
		}
	}
	if $shibboleth_idp::container::base::provider == "UNSET"
	{
		fail('A container provider must be configured')
	}
	class{"shibboleth_idp::container::${shibboleth_idp::container::base::provider}::config":
		require => Exec['install'] 
	}


	$install_dir = "${shibboleth_idp::params::shib_base}/${shibboleth_idp::params::install_dir}"
	$src_unpack_path = "${install_dir}/shibboleth-identityprovider-${shibboleth_idp::params::version}"
	$build_xml_file  = "${src_unpack_path}/src/installer/resources/build.xml"
	$install_properties_file  = "${src_unpack_path}/src/installer/resources/install.properties"

	Exec {path => ['/bin','/usr/bin', $src_unpack_path]}

	file { $shibboleth_idp::params::shib_base:
		ensure => "directory",
		alias  => "idp-base-dir",
	}

	file { $install_dir:
		ensure => "directory",
		alias  => "idp-install-dir",
		require=> File['idp-base-dir']
	}

	file{ "${install_dir}/shibboleth-identityprovider-${shibboleth_idp::params::version}.zip":
		ensure  => present,
		source  => "puppet:///modules/shibboleth_idp/dist/shibboleth-identityprovider-${shibboleth_idp::params::version}.zip",
		alias   => "idp-source-archive",
		require => File['idp-install-dir']
	} 

	exec { "unzip idp":
		command     => "unzip ${install_dir}/shibboleth-identityprovider-${shibboleth_idp::params::version}.zip",
		cwd         => $install_dir,
		subscribe   => File['idp-source-archive'],
		refreshonly => true,
		require     => File['idp-source-archive'],
	}

	augeas { "build.xml":
		lens    => "Xml.lns",
		incl    => $build_xml_file,
		context => "/files/${build_xml_file}",
		changes => [
			#"/project/target[@name='install']/input[@addproperty='idp.home.input']"
			"rm project/target[#attribute/name='install']/input[#attribute/addproperty='idp.home.input']",
			#/project/target[@name='install']/var[@name='idp.home']
			"rm project/target[#attribute/name='install']/var[#attribute/name='idp.home']",

			#"/project/target[@name='install']/if/then/input/[@addproperty="idp.hostname.input]"
			"rm project/target[#attribute/name='install']/if/then/input[#attribute/addproperty='idp.hostname.input']",
			#/project/target[@name='install']/if/then/var[@name='idp.hostname']
			"rm project/target[#attribute/name='install']/if/then/var[#attribute/name='idp.hostname']",

		],
		subscribe => Exec['unzip idp'],
		before    => Exec['install']
	}
	augeas { "install.properties":
		lens    => "Properties.lns",
		incl    => $install_properties_file,
		context => "/files/${install_properties_file}",
		changes => [
			"set idp.home ${shibboleth_idp::params::shib_base}",
			"set idp.hostname ${shibboleth_idp::params::idp_hostname}",
			"set install.config yes",
		],
		subscribe => Exec['unzip idp'],
		before    => Exec['install']
	}

	exec {'install':
		cwd	=> $src_unpack_path,
		command => "install.sh",
		before  => [File['conf-symlink'], File['log-symlink']]
	}

	file{'/etc/shibboleth-idp':
		alias  => "conf-symlink",
		force  => true,
		ensure => "link",
		target => "${shibboleth_idp::params::shib_base}/conf",
	}

	file{'/var/log/shibboleth-idp':
		alias => "log-symlink",
		force  => true,
		ensure => "link",
		target => "${shibboleth_idp::params::shib_base}/logs",
	}
	

}
