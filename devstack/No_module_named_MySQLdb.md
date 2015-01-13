现象：  
<pre><code>
2015-01-13 05:25:41.002 | 11802 CRITICAL keystone [-] ImportError: No module named MySQLdb
2015-01-13 05:25:41.002 | 11802 TRACE keystone Traceback (most recent call last):
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/opt/stack/keystone/bin/keystone-manage", line 44, in <module>
2015-01-13 05:25:41.002 | 11802 TRACE keystone     cli.main(argv=sys.argv, config_files=config_files)
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/opt/stack/keystone/keystone/cli.py", line 307, in main
2015-01-13 05:25:41.002 | 11802 TRACE keystone     CONF.command.cmd_class.main()
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/opt/stack/keystone/keystone/cli.py", line 74, in main
2015-01-13 05:25:41.002 | 11802 TRACE keystone     migration_helpers.sync_database_to_version(extension, version)
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/opt/stack/keystone/keystone/common/sql/migration_helpers.py", line 204, in sync_database_to_version
2015-01-13 05:25:41.002 | 11802 TRACE keystone     _sync_common_repo(version)
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/opt/stack/keystone/keystone/common/sql/migration_helpers.py", line 157, in _sync_common_repo
2015-01-13 05:25:41.002 | 11802 TRACE keystone     engine = sql.get_engine()
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/opt/stack/keystone/keystone/common/sql/core.py", line 188, in get_engine
2015-01-13 05:25:41.002 | 11802 TRACE keystone     return _get_engine_facade().get_engine()
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/opt/stack/keystone/keystone/common/sql/core.py", line 176, in _get_engine_facade
2015-01-13 05:25:41.002 | 11802 TRACE keystone     _engine_facade = db_session.EngineFacade.from_config(CONF)
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/usr/lib/python2.7/site-packages/oslo/db/sqlalchemy/session.py", line 816, in from_config
2015-01-13 05:25:41.002 | 11802 TRACE keystone     retry_interval=conf.database.retry_interval)
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/usr/lib/python2.7/site-packages/oslo/db/sqlalchemy/session.py", line 732, in __init__
2015-01-13 05:25:41.002 | 11802 TRACE keystone     **engine_kwargs)
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/usr/lib/python2.7/site-packages/oslo/db/sqlalchemy/session.py", line 391, in create_engine
2015-01-13 05:25:41.002 | 11802 TRACE keystone     engine = sqlalchemy.create_engine(url, **engine_args)
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/usr/lib64/python2.7/site-packages/sqlalchemy/engine/__init__.py", line 362, in create_engine
2015-01-13 05:25:41.002 | 11802 TRACE keystone     return strategy.create(*args, **kwargs)
2015-01-13 05:25:41.002 | 11802 TRACE keystone   File "/usr/lib64/python2.7/site-packages/sqlalchemy/engine/strategies.py", line 74, in create
2015-01-13 05:25:41.002 | 11802 TRACE keystone     dbapi = dialect_cls.dbapi(**dbapi_args)
2015-01-13 05:25:41.003 | 11802 TRACE keystone   File "/usr/lib64/python2.7/site-packages/sqlalchemy/connectors/mysqldb.py", line 64, in dbapi
2015-01-13 05:25:41.003 | 11802 TRACE keystone     return __import__('MySQLdb')
2015-01-13 05:25:41.003 | 11802 TRACE keystone ImportError: No module named MySQLdb
2015-01-13 05:25:41.003 | 11802 TRACE keystone
2015-01-13 05:25:41.038 | + exit_trap
2015-01-13 05:25:41.038 | + local r=1
</code></pre>

解决办法：
<pre><code>
yum install mariadb-devel.x86_64
pip install MySQL-python
</code></pre>
