[root@0ff2335e41d6 nova-docker]# python setup.py install
Download error on https://pypi.python.org/simple/pbr/: [Errno 8] _ssl.c:504: EOF occurred in violation of protocol -- Some packages may not be found!
Couldn't find index page for 'pbr' (maybe misspelled?)
Download error on https://pypi.python.org/simple/: [Errno 8] _ssl.c:504: EOF occurred in violation of protocol -- Some packages may not be found!
No local packages or download links found for pbr>=0.5.21,<1.0
Traceback (most recent call last):
  File "setup.py", line 22, in <module>
    pbr=True)
  File "/usr/lib64/python2.7/distutils/core.py", line 112, in setup
    _setup_distribution = dist = klass(attrs)
  File "/usr/lib/python2.7/site-packages/setuptools/dist.py", line 265, in __init__
    self.fetch_build_eggs(attrs.pop('setup_requires'))
  File "/usr/lib/python2.7/site-packages/setuptools/dist.py", line 289, in fetch_build_eggs
    parse_requirements(requires), installer=self.fetch_build_egg
  File "/usr/lib/python2.7/site-packages/pkg_resources.py", line 618, in resolve
    dist = best[req.key] = env.best_match(req, self, installer)
  File "/usr/lib/python2.7/site-packages/pkg_resources.py", line 862, in best_match
    return self.obtain(req, installer) # try and download/install
  File "/usr/lib/python2.7/site-packages/pkg_resources.py", line 874, in obtain
    return installer(requirement)
  File "/usr/lib/python2.7/site-packages/setuptools/dist.py", line 339, in fetch_build_egg
    return cmd.easy_install(req)
  File "/usr/lib/python2.7/site-packages/setuptools/command/easy_install.py", line 617, in easy_install
    raise DistutilsError(msg)
distutils.errors.DistutilsError: Could not find suitable distribution for Requirement.parse('pbr>=0.5.21,<1.0')


添加ssl key证书，配置pip仓库为国内仓库。


[root@A-172 nova-docker-stable-juno]# python /root/nova-docker-stable-juno/setup.py  install
ERROR:root:Error parsing
Traceback (most recent call last):
  File "/usr/lib/python2.7/site-packages/pbr/core.py", line 104, in pbr
    attrs = util.cfg_to_args(path)
  File "/usr/lib/python2.7/site-packages/pbr/util.py", line 238, in cfg_to_args
    pbr.hooks.setup_hook(config)
  File "/usr/lib/python2.7/site-packages/pbr/hooks/__init__.py", line 27, in setup_hook
    metadata_config.run()
  File "/usr/lib/python2.7/site-packages/pbr/hooks/base.py", line 29, in run
    self.hook()
  File "/usr/lib/python2.7/site-packages/pbr/hooks/metadata.py", line 28, in hook
    self.config['name'], self.config.get('version', None))
  File "/usr/lib/python2.7/site-packages/pbr/packaging.py", line 861, in get_version
    version = _get_version_from_git(pre_version)
  File "/usr/lib/python2.7/site-packages/pbr/packaging.py", line 802, in _get_version_from_git
    git_dir = _get_git_directory()
  File "/usr/lib/python2.7/site-packages/pbr/packaging.py", line 215, in _get_git_directory
    return _run_shell_command(['git', 'rev-parse', '--git-dir'])
  File "/usr/lib/python2.7/site-packages/pbr/packaging.py", line 204, in _run_shell_command
    env=newenv)
  File "/usr/lib64/python2.7/subprocess.py", line 711, in __init__
    errread, errwrite)
  File "/usr/lib64/python2.7/subprocess.py", line 1308, in _execute_child
    raise child_exception
OSError: [Errno 2] No such file or directory
error in setup command: Error parsing /root/nova-docker-stable-juno/setup.cfg: OSError: [Errno 2] No such file or directory


升级PBR版本从0.10.0到0.10.7


[root@A-172 nova-docker-stable-juno]# pip list |grep pbr
pbr (0.10.7)
[root@A-172 nova-docker-stable-juno]# python setup.py  install
ERROR:root:Error parsing
Traceback (most recent call last):
  File "/usr/lib/python2.7/site-packages/pbr/core.py", line 104, in pbr
    attrs = util.cfg_to_args(path)
  File "/usr/lib/python2.7/site-packages/pbr/util.py", line 238, in cfg_to_args
    pbr.hooks.setup_hook(config)
  File "/usr/lib/python2.7/site-packages/pbr/hooks/__init__.py", line 27, in setup_hook
    metadata_config.run()
  File "/usr/lib/python2.7/site-packages/pbr/hooks/base.py", line 29, in run
    self.hook()
  File "/usr/lib/python2.7/site-packages/pbr/hooks/metadata.py", line 28, in hook
    self.config['name'], self.config.get('version', None))
  File "/usr/lib/python2.7/site-packages/pbr/packaging.py", line 554, in get_version
    raise Exception("Versioning for this project requires either an sdist"
Exception: Versioning for this project requires either an sdist tarball, or access to an upstream git repository. Are you sure that git is installed?
error in setup command: Error parsing /root/nova-docker-stable-juno/setup.cfg: Exception: Versioning for this project requires either an sdist tarball, or access to an upstream git repository. Are you sure that git is installed?

安装git.
使用使用最新版juno代码。


2015-02-02 02:33:51.365 12138 ERROR nova.compute.manager [-] [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3] Instance failed to spawn
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3] Traceback (most recent call last):
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]   File "/usr/lib/python2.7/site-packages/nova/compute/manager.py", line 2243, in _build_resources
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]     yield resources
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]   File "/usr/lib/python2.7/site-packages/nova/compute/manager.py", line 2113, in _build_and_run_instance
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]     block_device_info=block_device_info)
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py", line 388, in spawn
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]     image = self.docker.inspect_image(self._encode_utf8(image_name))
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/client.py", line 36, in wrapper
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]     out = f(*args, **kwds)
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]   File "/usr/lib/python2.7/site-packages/docker/client.py", line 709, in inspect_image
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]     True
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]   File "/usr/lib/python2.7/site-packages/docker/client.py", line 98, in _result
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]     self._raise_for_status(response)
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]   File "/usr/lib/python2.7/site-packages/docker/client.py", line 94, in _raise_for_status
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]     raise errors.APIError(e, response, explanation=explanation)
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3] APIError: 404 Client Error: Not Found ("No such image: tutum/wordpress")
2015-02-02 02:33:51.365 12138 TRACE nova.compute.manager [instance: 425d4ed0-22ac-4845-b9dd-57ce794d12f3]


修改文件"/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py"：
spawn函数中增加try、catch：
         try:
             image = self.docker.inspect_image(self._encode_utf8(image_name))
         except errors.APIError:
             image = None


[root@A-172 ~]# tail -f  /var/log/nova/nova-compute.log|grep ac103eeb-a2b0-4b49-a863-c39bcb43975f
2015-02-02 04:11:55.326 28983 DEBUG nova.compute.utils [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Cannot load repository file: UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=10) notify_about_instance_usage /usr/lib/python2.7/site-packages/nova/compute/utils.py:307
2015-02-02 04:11:55.331 28983 DEBUG nova.compute.manager [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Build of instance ac103eeb-a2b0-4b49-a863-c39bcb43975f was re-scheduled: Cannot load repository file: UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=10) _do_build_and_run_instance /usr/lib/python2.7/site-packages/nova/compute/manager.py:2032
2015-02-02 04:11:55.530 28983 DEBUG nova.openstack.common.lockutils [-] Releasing semaphore "ac103eeb-a2b0-4b49-a863-c39bcb43975f" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:238


[root@A-172 ~]# grep ac103eeb-a2b0-4b49-a863-c39bcb43975f /var/log/nova/nova-compute.log
2015-02-02 04:11:39.952 28983 DEBUG nova.openstack.common.lockutils [-] Created new semaphore "ac103eeb-a2b0-4b49-a863-c39bcb43975f" internal_lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:206
2015-02-02 04:11:39.952 28983 DEBUG nova.openstack.common.lockutils [-] Acquired semaphore "ac103eeb-a2b0-4b49-a863-c39bcb43975f" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:229
2015-02-02 04:11:39.971 28983 AUDIT nova.compute.manager [req-94c8a6ed-40c5-4af3-b096-9b1360407c46 None] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Starting instance...
2015-02-02 04:11:40.074 28983 AUDIT nova.compute.claims [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Attempting claim: memory 512 MB, disk 1 GB
2015-02-02 04:11:40.074 28983 AUDIT nova.compute.claims [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Total memory: 48131 MB, used: 2560.00 MB
2015-02-02 04:11:40.074 28983 AUDIT nova.compute.claims [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] memory limit: 72196.50 MB, free: 69636.50 MB
2015-02-02 04:11:40.074 28983 AUDIT nova.compute.claims [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Total disk: 49 GB, used: 20.00 GB
2015-02-02 04:11:40.074 28983 AUDIT nova.compute.claims [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] disk limit not specified, defaulting to unlimited
2015-02-02 04:11:40.085 28983 AUDIT nova.compute.claims [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Claim successful
2015-02-02 04:11:40.318 28983 DEBUG nova.compute.manager [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Allocating IP information in the background. _allocate_network_async /usr/lib/python2.7/site-packages/nova/compute/manager.py:1628
2015-02-02 04:11:40.318 28983 DEBUG nova.network.neutronv2.api [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] allocate_for_instance() allocate_for_instance /usr/lib/python2.7/site-packages/nova/network/neutronv2/api.py:279
REQ: curl -i http://186.100.21.172:9696/v2.0/ports.json -X POST -H "X-Auth-Token: 2ea4ae5d5cf7412da7b07cdb94d1f81a" -H "User-Agent: python-neutronclient" -d '{"port": {"binding:host_id": "A-172", "admin_state_up": true, "network_id": "2510a249-1665-4184-afc8-62a2eccf6c3b", "tenant_id": "3cf2410b5f554653a93796982657984b", "device_owner": "compute:nova", "security_groups": ["462e4fb8-539a-489e-8d41-14f0234f71cf"], "device_id": "ac103eeb-a2b0-4b49-a863-c39bcb43975f"}}'
2015-02-02 04:11:40.748 28983 DEBUG neutronclient.client [-] RESP:201 {'date': 'Mon, 02 Feb 2015 09:11:40 GMT', 'content-length': '724', 'content-type': 'application/json; charset=UTF-8', 'x-openstack-request-id': 'req-4e7661be-9921-4d16-b5d7-89cadc9e6185'} {"port": {"status": "DOWN", "binding:host_id": "A-172", "allowed_address_pairs": [], "extra_dhcp_opts": [], "device_owner": "compute:nova", "binding:profile": {}, "fixed_ips": [{"subnet_id": "5c057651-2193-48b2-9883-f57e352ff344", "ip_address": "10.0.0.11"}], "id": "2fee26da-9b54-46bc-af80-0c2daee06f6e", "security_groups": ["462e4fb8-539a-489e-8d41-14f0234f71cf"], "device_id": "ac103eeb-a2b0-4b49-a863-c39bcb43975f", "name": "", "admin_state_up": true, "network_id": "2510a249-1665-4184-afc8-62a2eccf6c3b", "tenant_id": "3cf2410b5f554653a93796982657984b", "binding:vif_details": {"port_filter": true, "ovs_hybrid_plug": true}, "binding:vnic_type": "normal", "binding:vif_type": "ovs", "mac_address": "fa:16:3e:5a:a4:93"}}
2015-02-02 04:11:40.753 28983 DEBUG nova.network.neutronv2.api [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Successfully created port: 2fee26da-9b54-46bc-af80-0c2daee06f6e _create_port /usr/lib/python2.7/site-packages/nova/network/neutronv2/api.py:216
2015-02-02 04:11:40.753 28983 DEBUG nova.openstack.common.lockutils [-] Created new semaphore "refresh_cache-ac103eeb-a2b0-4b49-a863-c39bcb43975f" internal_lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:206
2015-02-02 04:11:40.753 28983 DEBUG nova.openstack.common.lockutils [-] Acquired semaphore "refresh_cache-ac103eeb-a2b0-4b49-a863-c39bcb43975f" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:229
2015-02-02 04:11:40.753 28983 DEBUG nova.network.neutronv2.api [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] get_instance_nw_info() _get_instance_nw_info /usr/lib/python2.7/site-packages/nova/network/neutronv2/api.py:610
REQ: curl -i http://186.100.21.172:9696/v2.0/ports.json?tenant_id=3cf2410b5f554653a93796982657984b&device_id=ac103eeb-a2b0-4b49-a863-c39bcb43975f -X GET -H "X-Auth-Token: 2ea4ae5d5cf7412da7b07cdb94d1f81a" -H "User-Agent: python-neutronclient"
2015-02-02 04:11:41.346 28983 DEBUG neutronclient.client [-] RESP:200 {'date': 'Mon, 02 Feb 2015 09:11:40 GMT', 'content-length': '727', 'content-type': 'application/json; charset=UTF-8', 'x-openstack-request-id': 'req-f0322351-f75a-4a25-b8b9-f089e63474fb'} {"ports": [{"status": "DOWN", "binding:host_id": "A-172", "allowed_address_pairs": [], "extra_dhcp_opts": [], "device_owner": "compute:nova", "binding:profile": {}, "fixed_ips": [{"subnet_id": "5c057651-2193-48b2-9883-f57e352ff344", "ip_address": "10.0.0.11"}], "id": "2fee26da-9b54-46bc-af80-0c2daee06f6e", "security_groups": ["462e4fb8-539a-489e-8d41-14f0234f71cf"], "device_id": "ac103eeb-a2b0-4b49-a863-c39bcb43975f", "name": "", "admin_state_up": true, "network_id": "2510a249-1665-4184-afc8-62a2eccf6c3b", "tenant_id": "3cf2410b5f554653a93796982657984b", "binding:vif_details": {"port_filter": true, "ovs_hybrid_plug": true}, "binding:vnic_type": "normal", "binding:vif_type": "ovs", "mac_address": "fa:16:3e:5a:a4:93"}]}
2015-02-02 04:11:43.671 28983 DEBUG nova.openstack.common.lockutils [-] Releasing semaphore "refresh_cache-ac103eeb-a2b0-4b49-a863-c39bcb43975f" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:238
2015-02-02 04:11:43.671 28983 DEBUG nova.compute.manager [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Instance network_info: |[VIF({'profile': {}, 'ovs_interfaceid': u'2fee26da-9b54-46bc-af80-0c2daee06f6e', 'network': Network({'bridge': 'br-int', 'subnets': [Subnet({'ips': [FixedIP({'meta': {}, 'version': 4, 'type': 'fixed', 'floating_ips': [], 'address': u'10.0.0.11'})], 'version': 4, 'meta': {'dhcp_server': u'10.0.0.3'}, 'dns': [], 'routes': [], 'cidr': u'10.0.0.0/24', 'gateway': IP({'meta': {}, 'version': 4, 'type': 'gateway', 'address': u'10.0.0.1'})})], 'meta': {'injected': False, 'tenant_id': u'3cf2410b5f554653a93796982657984b'}, 'id': u'2510a249-1665-4184-afc8-62a2eccf6c3b', 'label': u'private'}), 'devname': u'tap2fee26da-9b', 'vnic_type': u'normal', 'qbh_params': None, 'meta': {}, 'details': {u'port_filter': True, u'ovs_hybrid_plug': True}, 'address': u'fa:16:3e:5a:a4:93', 'active': False, 'type': u'ovs', 'id': u'2fee26da-9b54-46bc-af80-0c2daee06f6e', 'qbg_params': None})]| _allocate_network_async /usr/lib/python2.7/site-packages/nova/compute/manager.py:1645
2015-02-02 04:11:53.529 28983 WARNING novadocker.virt.docker.driver [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Cannot load repository file: UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=10)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Traceback (most recent call last):
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py", line 351, in _pull_missing_image
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     out_path
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/client.py", line 36, in wrapper
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     out = f(*args, **kwds)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/client.py", line 94, in load_repository_file
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     self.load_image(fh)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/client.py", line 36, in wrapper
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     out = f(*args, **kwds)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/docker/client.py", line 724, in load_image
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     res = self._post(self._url("/images/load"), data=data)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/docker/client.py", line 78, in _post
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     return self.post(url, **self._set_request_timeout(kwargs))
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/client.py", line 36, in wrapper
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     out = f(*args, **kwds)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/requests/sessions.py", line 498, in post
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     return self.request('POST', url, data=data, **kwargs)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/client.py", line 36, in wrapper
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     out = f(*args, **kwds)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/requests/sessions.py", line 456, in request
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     resp = self.send(prep, **send_kwargs)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/client.py", line 36, in wrapper
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     out = f(*args, **kwds)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/requests/sessions.py", line 559, in send
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     r = adapter.send(request, **kwargs)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/requests/adapters.py", line 384, in send
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     raise Timeout(e, request=request)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Timeout: UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=10)
2015-02-02 04:11:53.529 28983 TRACE novadocker.virt.docker.driver [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]
2015-02-02 04:11:53.621 28983 ERROR nova.compute.manager [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Instance failed to spawn
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Traceback (most recent call last):
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/nova/compute/manager.py", line 2243, in _build_resources
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     yield resources
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/nova/compute/manager.py", line 2113, in _build_and_run_instance
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     block_device_info=block_device_info)
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py", line 394, in spawn
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     image = self._pull_missing_image(context, image_meta, instance)
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py", line 358, in _pull_missing_image
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]     instance_id=image_meta['name'])
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] NovaException: Cannot load repository file: UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=10)
2015-02-02 04:11:53.621 28983 TRACE nova.compute.manager [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f]
2015-02-02 04:11:53.622 28983 AUDIT nova.compute.manager [req-94c8a6ed-40c5-4af3-b096-9b1360407c46 None] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Terminating instance
2015-02-02 04:11:53.642 28983 DEBUG nova.compute.claims [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Aborting claim: [Claim: 512 MB memory, 1 GB disk] abort /usr/lib/python2.7/site-packages/nova/compute/claims.py:128
2015-02-02 04:11:55.326 28983 DEBUG nova.compute.utils [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Cannot load repository file: UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=10) notify_about_instance_usage /usr/lib/python2.7/site-packages/nova/compute/utils.py:307
2015-02-02 04:11:55.331 28983 DEBUG nova.compute.manager [-] [instance: ac103eeb-a2b0-4b49-a863-c39bcb43975f] Build of instance ac103eeb-a2b0-4b49-a863-c39bcb43975f was re-scheduled: Cannot load repository file: UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=10) _do_build_and_run_instance /usr/lib/python2.7/site-packages/nova/compute/manager.py:2032
2015-02-02 04:11:55.530 28983 DEBUG nova.openstack.common.lockutils [-] Releasing semaphore "ac103eeb-a2b0-4b49-a863-c39bcb43975f" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:238





[root@A-172 ~]# grep 84729308-1dbd-4741-beb5-df58d22cdb6e  /var/log/nova/nova-compute.log
2015-02-02 04:18:40.023 28983 DEBUG nova.openstack.common.lockutils [-] Created new semaphore "84729308-1dbd-4741-beb5-df58d22cdb6e" internal_lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:206
2015-02-02 04:18:40.024 28983 DEBUG nova.openstack.common.lockutils [-] Acquired semaphore "84729308-1dbd-4741-beb5-df58d22cdb6e" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:229
2015-02-02 04:18:40.047 28983 AUDIT nova.compute.manager [req-561c3318-310f-4530-bea3-13f9d056069a None] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Starting instance...
2015-02-02 04:18:40.141 28983 AUDIT nova.compute.claims [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Attempting claim: memory 512 MB, disk 1 GB
2015-02-02 04:18:40.141 28983 AUDIT nova.compute.claims [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Total memory: 48131 MB, used: 2560.00 MB
2015-02-02 04:18:40.141 28983 AUDIT nova.compute.claims [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] memory limit: 72196.50 MB, free: 69636.50 MB
2015-02-02 04:18:40.141 28983 AUDIT nova.compute.claims [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Total disk: 49 GB, used: 20.00 GB
2015-02-02 04:18:40.142 28983 AUDIT nova.compute.claims [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] disk limit not specified, defaulting to unlimited
2015-02-02 04:18:40.154 28983 AUDIT nova.compute.claims [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Claim successful
2015-02-02 04:18:40.486 28983 DEBUG nova.compute.manager [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Allocating IP information in the background. _allocate_network_async /usr/lib/python2.7/site-packages/nova/compute/manager.py:1628
2015-02-02 04:18:40.486 28983 DEBUG nova.network.neutronv2.api [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] allocate_for_instance() allocate_for_instance /usr/lib/python2.7/site-packages/nova/network/neutronv2/api.py:279
REQ: curl -i http://186.100.21.172:9696/v2.0/ports.json -X POST -H "X-Auth-Token: 2ea4ae5d5cf7412da7b07cdb94d1f81a" -H "User-Agent: python-neutronclient" -d '{"port": {"binding:host_id": "A-172", "admin_state_up": true, "network_id": "2510a249-1665-4184-afc8-62a2eccf6c3b", "tenant_id": "3cf2410b5f554653a93796982657984b", "device_owner": "compute:nova", "security_groups": ["462e4fb8-539a-489e-8d41-14f0234f71cf"], "device_id": "84729308-1dbd-4741-beb5-df58d22cdb6e"}}'
2015-02-02 04:18:40.899 28983 DEBUG neutronclient.client [-] RESP:201 {'date': 'Mon, 02 Feb 2015 09:18:40 GMT', 'content-length': '724', 'content-type': 'application/json; charset=UTF-8', 'x-openstack-request-id': 'req-f0a18bb6-1d91-4410-b4f4-798bfe5d7bdb'} {"port": {"status": "DOWN", "binding:host_id": "A-172", "allowed_address_pairs": [], "extra_dhcp_opts": [], "device_owner": "compute:nova", "binding:profile": {}, "fixed_ips": [{"subnet_id": "5c057651-2193-48b2-9883-f57e352ff344", "ip_address": "10.0.0.12"}], "id": "f6504747-2a3a-4682-a2ea-3f766f295dc9", "security_groups": ["462e4fb8-539a-489e-8d41-14f0234f71cf"], "device_id": "84729308-1dbd-4741-beb5-df58d22cdb6e", "name": "", "admin_state_up": true, "network_id": "2510a249-1665-4184-afc8-62a2eccf6c3b", "tenant_id": "3cf2410b5f554653a93796982657984b", "binding:vif_details": {"port_filter": true, "ovs_hybrid_plug": true}, "binding:vnic_type": "normal", "binding:vif_type": "ovs", "mac_address": "fa:16:3e:f4:0c:b3"}}
2015-02-02 04:18:40.903 28983 DEBUG nova.network.neutronv2.api [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Successfully created port: f6504747-2a3a-4682-a2ea-3f766f295dc9 _create_port /usr/lib/python2.7/site-packages/nova/network/neutronv2/api.py:216
2015-02-02 04:18:40.904 28983 DEBUG nova.openstack.common.lockutils [-] Created new semaphore "refresh_cache-84729308-1dbd-4741-beb5-df58d22cdb6e" internal_lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:206
2015-02-02 04:18:40.904 28983 DEBUG nova.openstack.common.lockutils [-] Acquired semaphore "refresh_cache-84729308-1dbd-4741-beb5-df58d22cdb6e" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:229
2015-02-02 04:18:40.904 28983 DEBUG nova.network.neutronv2.api [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] get_instance_nw_info() _get_instance_nw_info /usr/lib/python2.7/site-packages/nova/network/neutronv2/api.py:610
REQ: curl -i http://186.100.21.172:9696/v2.0/ports.json?tenant_id=3cf2410b5f554653a93796982657984b&device_id=84729308-1dbd-4741-beb5-df58d22cdb6e -X GET -H "X-Auth-Token: 2ea4ae5d5cf7412da7b07cdb94d1f81a" -H "User-Agent: python-neutronclient"
2015-02-02 04:18:41.008 28983 DEBUG neutronclient.client [-] RESP:200 {'date': 'Mon, 02 Feb 2015 09:18:41 GMT', 'content-length': '727', 'content-type': 'application/json; charset=UTF-8', 'x-openstack-request-id': 'req-77ccac17-bf7d-4873-a7cd-fea40dcad12a'} {"ports": [{"status": "DOWN", "binding:host_id": "A-172", "allowed_address_pairs": [], "extra_dhcp_opts": [], "device_owner": "compute:nova", "binding:profile": {}, "fixed_ips": [{"subnet_id": "5c057651-2193-48b2-9883-f57e352ff344", "ip_address": "10.0.0.12"}], "id": "f6504747-2a3a-4682-a2ea-3f766f295dc9", "security_groups": ["462e4fb8-539a-489e-8d41-14f0234f71cf"], "device_id": "84729308-1dbd-4741-beb5-df58d22cdb6e", "name": "", "admin_state_up": true, "network_id": "2510a249-1665-4184-afc8-62a2eccf6c3b", "tenant_id": "3cf2410b5f554653a93796982657984b", "binding:vif_details": {"port_filter": true, "ovs_hybrid_plug": true}, "binding:vnic_type": "normal", "binding:vif_type": "ovs", "mac_address": "fa:16:3e:f4:0c:b3"}]}
2015-02-02 04:18:41.114 28983 DEBUG nova.openstack.common.lockutils [-] Releasing semaphore "refresh_cache-84729308-1dbd-4741-beb5-df58d22cdb6e" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:238
2015-02-02 04:18:41.114 28983 DEBUG nova.compute.manager [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Instance network_info: |[VIF({'profile': {}, 'ovs_interfaceid': u'f6504747-2a3a-4682-a2ea-3f766f295dc9', 'network': Network({'bridge': 'br-int', 'subnets': [Subnet({'ips': [FixedIP({'meta': {}, 'version': 4, 'type': 'fixed', 'floating_ips': [], 'address': u'10.0.0.12'})], 'version': 4, 'meta': {'dhcp_server': u'10.0.0.3'}, 'dns': [], 'routes': [], 'cidr': u'10.0.0.0/24', 'gateway': IP({'meta': {}, 'version': 4, 'type': 'gateway', 'address': u'10.0.0.1'})})], 'meta': {'injected': False, 'tenant_id': u'3cf2410b5f554653a93796982657984b'}, 'id': u'2510a249-1665-4184-afc8-62a2eccf6c3b', 'label': u'private'}), 'devname': u'tapf6504747-2a', 'vnic_type': u'normal', 'qbh_params': None, 'meta': {}, 'details': {u'port_filter': True, u'ovs_hybrid_plug': True}, 'address': u'fa:16:3e:f4:0c:b3', 'active': False, 'type': u'ovs', 'id': u'f6504747-2a3a-4682-a2ea-3f766f295dc9', 'qbg_params': None})]| _allocate_network_async /usr/lib/python2.7/site-packages/nova/compute/manager.py:1645
2015-02-02 04:18:41.730 28983 DEBUG novadocker.virt.docker.vifs [-] plug vif_type=ovs instance=Instance(access_ip_v4=None,access_ip_v6=None,architecture=None,auto_disk_config=True,availability_zone='nova',cell_name=None,cleaned=False,config_drive='',created_at=2015-02-02T09:18:39Z,default_ephemeral_device=None,default_swap_device=None,deleted=False,deleted_at=None,disable_terminate=False,display_description='docker3',display_name='docker3',ephemeral_gb=0,ephemeral_key_uuid=None,fault=<?>,host='A-172',hostname='docker3',id=10,image_ref='b8e12702-3fd1-4847-b018-ac8ba6edead7',info_cache=InstanceInfoCache,instance_type_id=2,kernel_id='',key_data=None,key_name=None,launch_index=0,launched_at=None,launched_on='A-172',locked=False,locked_by=None,memory_mb=512,metadata={},node='A-172',numa_topology=None,os_type=None,pci_devices=<?>,power_state=0,progress=0,project_id='3cf2410b5f554653a93796982657984b',ramdisk_id='',reservation_id='r-za470usw',root_device_name='/dev/sda',root_gb=1,scheduled_at=None,security_groups=SecurityGroupList,shutdown_terminate=False,system_metadata={image_base_image_ref='b8e12702-3fd1-4847-b018-ac8ba6edead7',image_container_format='docker',image_disk_format='raw',image_min_disk='1',image_min_ram='0',instance_type_ephemeral_gb='0',instance_type_flavorid='1',instance_type_id='2',instance_type_memory_mb='512',instance_type_name='m1.tiny',instance_type_root_gb='1',instance_type_rxtx_factor='1.0',instance_type_swap='0',instance_type_vcpu_weight=None,instance_type_vcpus='1',network_allocated='True'},task_state='spawning',terminated_at=None,updated_at=2015-02-02T09:18:40Z,user_data=None,user_id='d77e4a5699c34c45b71368dbb0fc2aec',uuid=84729308-1dbd-4741-beb5-df58d22cdb6e,vcpus=1,vm_mode=None,vm_state='building') vif=VIF({'profile': {}, 'ovs_interfaceid': u'f6504747-2a3a-4682-a2ea-3f766f295dc9', 'network': Network({'bridge': 'br-int', 'subnets': [Subnet({'ips': [FixedIP({'meta': {}, 'version': 4, 'type': 'fixed', 'floating_ips': [], 'address': u'10.0.0.12'})], 'version': 4, 'meta': {'dhcp_server': u'10.0.0.3'}, 'dns': [], 'routes': [], 'cidr': u'10.0.0.0/24', 'gateway': IP({'meta': {}, 'version': 4, 'type': 'gateway', 'address': u'10.0.0.1'})})], 'meta': {'injected': False, 'tenant_id': u'3cf2410b5f554653a93796982657984b'}, 'id': u'2510a249-1665-4184-afc8-62a2eccf6c3b', 'label': u'private'}), 'devname': u'tapf6504747-2a', 'vnic_type': u'normal', 'qbh_params': None, 'meta': {}, 'details': {u'port_filter': True, u'ovs_hybrid_plug': True}, 'address': u'fa:16:3e:f4:0c:b3', 'active': False, 'type': u'ovs', 'id': u'f6504747-2a3a-4682-a2ea-3f766f295dc9', 'qbg_params': None}) plug /usr/lib/python2.7/site-packages/novadocker/virt/docker/vifs.py:50
2015-02-02 04:18:41.835 28983 DEBUG nova.openstack.common.processutils [-] Running cmd (subprocess): sudo nova-rootwrap /etc/nova/rootwrap.conf ovs-vsctl --timeout=120 -- --if-exists del-port tapf6504747-2a -- add-port br-int tapf6504747-2a -- set Interface tapf6504747-2a external-ids:iface-id=f6504747-2a3a-4682-a2ea-3f766f295dc9 external-ids:iface-status=active external-ids:attached-mac=fa:16:3e:f4:0c:b3 external-ids:vm-uuid=84729308-1dbd-4741-beb5-df58d22cdb6e execute /usr/lib/python2.7/site-packages/nova/openstack/common/processutils.py:161
2015-02-02 04:18:42.120 28983 WARNING novadocker.virt.docker.driver [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Cannot setup network: Unexpected error while running command.
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Traceback (most recent call last):
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py", line 368, in _start_container
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]     self._attach_vifs(instance, network_info)
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py", line 209, in _attach_vifs
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]     run_as_root=True)
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]   File "/usr/lib/python2.7/site-packages/nova/utils.py", line 163, in execute
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]     return processutils.execute(*cmd, **kwargs)
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]   File "/usr/lib/python2.7/site-packages/nova/openstack/common/processutils.py", line 203, in execute
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]     cmd=sanitized_cmd)
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] ProcessExecutionError: Unexpected error while running command.
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Command: sudo nova-rootwrap /etc/nova/rootwrap.conf ln -sf /proc/31224/ns/net /var/run/netns/237d77f9c2c569055c689c9f900cd8150a112efffe7cdd1261b796be8d35afc0
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Exit code: 99
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Stdout: u''
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Stderr: u'/usr/bin/nova-rootwrap: Unauthorized command: ln -sf /proc/31224/ns/net /var/run/netns/237d77f9c2c569055c689c9f900cd8150a112efffe7cdd1261b796be8d35afc0 (no filter matched)\n'
2015-02-02 04:18:42.120 28983 TRACE novadocker.virt.docker.driver [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]
2015-02-02 04:18:44.097 28983 ERROR nova.compute.manager [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Instance failed to spawn
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Traceback (most recent call last):
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]   File "/usr/lib/python2.7/site-packages/nova/compute/manager.py", line 2243, in _build_resources
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]     yield resources
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]   File "/usr/lib/python2.7/site-packages/nova/compute/manager.py", line 2113, in _build_and_run_instance
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]     block_device_info=block_device_info)
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py", line 408, in spawn
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]     self._start_container(container_id, instance, network_info)
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]   File "/usr/lib/python2.7/site-packages/novadocker/virt/docker/driver.py", line 376, in _start_container
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]     instance_id=instance['name'])
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] InstanceDeployFailure: Cannot setup network: Unexpected error while running command.
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Command: sudo nova-rootwrap /etc/nova/rootwrap.conf ln -sf /proc/31224/ns/net /var/run/netns/237d77f9c2c569055c689c9f900cd8150a112efffe7cdd1261b796be8d35afc0
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Exit code: 99
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Stdout: u''
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Stderr: u'/usr/bin/nova-rootwrap: Unauthorized command: ln -sf /proc/31224/ns/net /var/run/netns/237d77f9c2c569055c689c9f900cd8150a112efffe7cdd1261b796be8d35afc0 (no filter matched)\n'
2015-02-02 04:18:44.097 28983 TRACE nova.compute.manager [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e]
2015-02-02 04:18:44.099 28983 AUDIT nova.compute.manager [req-561c3318-310f-4530-bea3-13f9d056069a None] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Terminating instance
2015-02-02 04:18:44.116 28983 DEBUG nova.compute.claims [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Aborting claim: [Claim: 512 MB memory, 1 GB disk] abort /usr/lib/python2.7/site-packages/nova/compute/claims.py:128
2015-02-02 04:18:44.149 28983 DEBUG nova.compute.utils [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Cannot setup network: Unexpected error while running command.
2015-02-02 04:18:44.154 28983 DEBUG nova.compute.manager [-] [instance: 84729308-1dbd-4741-beb5-df58d22cdb6e] Build of instance 84729308-1dbd-4741-beb5-df58d22cdb6e was re-scheduled: Cannot setup network: Unexpected error while running command.
2015-02-02 04:18:44.389 28983 DEBUG nova.openstack.common.lockutils [-] Releasing semaphore "84729308-1dbd-4741-beb5-df58d22cdb6e" lock /usr/lib/python2.7/site-packages/nova/openstack/common/lockutils.py:238


创建 /usr/share/nova/rootwrap/docker.filters
文件内容：
# nova-rootwrap command filters for setting up network in the docker driver
# This file should be owned by (and only-writeable by) the root user

[Filters]
# nova/virt/docker/driver.py: 'ln', '-sf', '/var/run/netns/.*'
ln: CommandFilter, /bin/ln, root


novadocker 创建的容器与在同一网络中的虚拟机不能互相ping通。
原因分析：目前nova-docker不支持安全组。因此未配置安全组规则。

解决办法：
安全组中增加规则。
 nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0





