class node_setup {

    ## User Authentication
    # set NIS domain
    file {"/etc/defaultdomain": source => "puppet:///modules/nodes/defaultdomain"} ->
    # set yp server
    file {"/etc/yp.conf": source => "puppet:///modules/nodes/yp.conf"} ->
    # install NIS
    package {"nis": ensure => installed} ->
    # update passwd, shadow and gshadow
    file_line {'update passwd': path => '/etc/passwd', line => '+::::::'} ->
    file_line {'update shadow': path => '/etc/shadow', line => '+::::::::'} ->
    file_line {'update group': path => '/etc/group', line => '+:::'} ->
    file_line {'update gshadow': path => '/etc/gshadow', line => '+:::'}


    ## Network File System
    package {"nfs-common": ensure => installed}
    file_line {'nfs home':
        path => '/etc/fstab',
        line => '192.168.10.1:/home      /home      nfs     rw,hard,intr   0 0',
        require => Package["nfs-common"],
        notify => Exec['nfs mount'],
    }
    file_line {'nfs opt':
        path => '/etc/fstab',
        line => '192.168.10.1:/opt       /opt       nfs     rw,hard,intr   0 0',
        require => Package["nfs-common"],
        notify => Exec['nfs mount'],
    }
    exec {'nfs mount':
        command => '/bin/mount -a',
        path => '/usr/local/bin',
        refreshonly => true,
    }


    ## NTP (Time server)
    ## make sure the time is the same on the master
    ## and the nodes
    package {'ntp': ensure => installed}
    service {'ntp':
        ensure => 'running',
        enable => 'true',
        require => Package['ntp'],
    }
    file {'/etc/ntp.conf':
        source => "puppet:///modules/nodes/ntp.conf",
        require => Package['ntp'],
        notify => Service['ntp'],
    }


    ## SLURM setup
    package {'slurm-llnl': ensure => installed}
    package {'munge': ensure => installed}
    # slurm client
    service {"slurmd":
        ensure => 'running',
        enable => 'true',
        require => Package['slurm-llnl'],
    }

    ## Munge (SLURM authentication)
    service {"munge":
        ensure => 'running',
        enable => 'true',
        require => Package['munge'],
    }
    file{'/etc/slurm-llnl/slurm.conf':
        source => "puppet:///modules/nodes/slurm.conf",
        owner => "root",
        group => "root",
        require => Package['slurm-llnl'],
        notify => Service['slurmd'],
    }
    file{'/etc/munge/munge.key':
        source => "puppet:///modules/nodes/munge.key",
        owner => "munge",
        group => "munge",
        mode => "400",
        notify => Service['munge'],
        require => Package['munge'],
    }



    ## GAMESS setup
    # please see for more information
    # http://computerandchemistry.blogspot.com/2014/02/compiling-and-setting-up-gamess.html
    file_line {'set shmmax':
        path => '/etc/sysctl.conf',
        line => 'kernel.shmmax=1610612736',
    }


    ## Change permission of scratch
    file {"/scratch":
        ensure  => directory,
        owner   => root,
        group   => sunshine,
        mode    => '770',
        recurse => false,
    }


    ## TODO
    ## root ssh access
    # file path /root/.ssh/
    # authorized_keys
    file {"/root/.ssh":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '700',
        recurse => false,
    }
    file{'/root/.ssh/authorized_keys':
        source => "puppet:///modules/nodes/authorized_keys",
        owner => "root",
        group => "root",
        require => File['/root/.ssh'],
    }


    ## Default Packages
    package {"zsh": ensure => installed}
    package {"csh": ensure => installed}
    package {"vim": ensure => installed}

    package {"gfortran": ensure => installed}

    package {"stress": ensure => installed}


}
