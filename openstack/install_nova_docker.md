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
