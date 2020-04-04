#########
telerista
#########

telegraf_ agent for Arista switches

.. contents:: :depth: 3

Features
========

* Designed to run directly on your Arista switch
* Collects the following data regarding your switch

  * Linux system stats (cpu, memory, kernel, etc)

  * LANZ records (if configured)

  * Openconfig gNMI interface statistics

* Stores data in InfluxDB
* Configurable global tags added to all measurements
* Includes sample Grafana dashboards

Switch configuration
--------------------

LANZ
~~~~
LANZ_ streaming must be enabled globally on the switch

.. code-block::

    EOS#configure terminal
    EOS(config)#queue-monitor streaming
    EOS(config-qm-streaming)#no shutdown
    EOS(config-qm-streaming)#end

Note that by default, all connections are accepted.  Please refer to
the manual for information regarding securing the streaming server

OpenConfig GNMI
~~~~~~~~~~~~~~~
Arista support for `OpenConfig gNMI telemetry streaming`_ was added in 4.20.2.1F_
It can be enabled in one of two ways:

Global listener Authenticated with optional TLS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Using the management api config stanza, an AAA authenticated OpenConfig
listener can be started This requires the ``GNMI_USERNAME`` and
``GNMI_PASSWORD`` environment variables to be set.

..  code-block::

      EOS#configure terminal
      EOS(config)#management api gnmi
      EOS(config-mgmt-api-gnmi)#transport grpc <name>
      EOS(config-gnmi-transport-name)#no shutdown
      EOS(config-gnmi-transport-name)#end

Refer to the command reference for additional options regarding VRF, ACL, and
TLS profile options

Local, unauthenticated listener
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Using the daemon config stanza, we can start an OpenConfig process that
bypasses AAA and only listens on localhost.  Depending on your version of EOS,
the OpenConfig binary could be at either `/bin` or `/usr/bin`

.. code-block:: 

    EOS#configure terminal
    EOS(config)#daemon OpenConfig
    EOS(config-daemon-OpenConfig)#exec /usr/bin/OpenConfig -disableaaa -grpcaddr 127:0.0.1:6030
    EOS(config-daemon-OpenConfig)#no shutdown
    EOS(config-daemon-OpenConfig)#end

Container execution
~~~~~~~~~~~~~~~~~~~
For the container to have access to all the resources needed to read system
statistics, a long list of container options must be passed to Docker.
Be sure to set the correct values for your hostname, nameserver, and environment
variables

.. code-block::

    EOS#configure terminal
    EOS(config)#container-manager
    EOS(config-container-mgr)#container telerista
    EOS(config-container-mgr-container-telerista)#image imctrading/telerista:latest
    EOS(config-container-mgr-container-telerista)#options --dns=127.0.0.1 --log-opt max-size=1m --log-opt max-file=3 --network=host -e HOSTNAME=EOS -e INFLUX_URL="http://influxdb:8086" -e "HOST_PROC=/rootfs/proc" -e "PROC_ROOT=/rootfs/proc" -e "HOST_SYS=/rootfs/sys" -e "HOST_ETC=/rootfs/etc" -e "HOST_MOUNT_PREFIX=/rootfs" -e TAG_foo=bar -v /sys:/rootfs/sys:ro -v /proc:/rootfs/proc:ro -v /etc:/rootfs/etc:ro
    EOS(config-container-mgr-container-telerista)#on-boot
    EOS(config-container-mgr-container-telerista)#end

Variable reference
------------------
The following environment variables can be set:

.. list-table::
    :header-rows: 1

    * - Name
      - Default
      - Description
    * - ``HOSTNAME``
      -
      - Set the hostname variable inside the container.
    * - ``INFLUX_URL``
      - 
      - URL of your InfluxDB instance (http://influxdb:8086)
    * - ``INFLUX_DB``
      - ``telegraf``
      - Name of the InfluxDB database to use
    * - ``INFLUX_USERNAME``
      - 
      - Username for InfluxDB instance (if authentication enabled)
    * - ``INFLUX_PASSWORD``
      - 
      - Password for InfluxDB instance (if authentication enabled)
    * - ``GNMI_SERVER``
      - ``localhost:6030``
      - Host and port for OpenConfig gNMI instance
    * - ``GNMI_USERNAME``
      -
      - Username for gNMI (if AAA enabled)
    * - ``GNMI_PASSWORD``
      -
      - Password for gNMI (if AAA enabled)
    * - ``LANZ_SERVER``
      - ``localhost:50001``
      - Host and port for LANZ streaming server
    * - ``TAG_*``
      - 
      - All environment variables prefixed with ``TAG_`` will have the prefix
        stripped and set as a global tag for all measurements


.. _telegraf: https://www.influxdata.com/time-series-platform/telegraf/
.. _LANZ: https://www.arista.com/en/um-eos/eos-section-44-3-configuring-lanz#ww1149292
.. _`4.20.2.1F`: https://eos.arista.com/openconfig-4-20-2-1f-release-notes/
.. _OpenConfig gNMI telemetry streaming: https://github.com/openconfig/reference/tree/master/rpc/gnmi
