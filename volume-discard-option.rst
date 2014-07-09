..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

==========================================
volume discard option
==========================================

https://blueprints.launchpad.net/cinder/+spec/volume-discard-option

Currently, libvirt/qemu has support discard option when attaching a volume
to an instance. With this feature, the unmap/trim command can be send from
guest to the final storage device. It's valualbe for the volume backed on
SSD storages or the storage diskarray which suppport this command.

So nova needs to get assist from the cinder to decide whether to enable the
discard option when attaching the cinder volume.

This spec aims to add the assist to support enabling discard for cinder
volumes.

Problem description
===================

* Attaching a cinder volume to an instance
  If the cinder volume is suitable to enable discard(for example based on SSD
  storage), we hope to tell nova that the volume is happy to be attached
  to an instance with discard option.

Proposed change
===============

* "discard" property in cinder volume is implemented as an admin metadata.

Alternatives
------------

Add a new colume to the volume table in cinder to record "discard" property.
There is two reasons to not use this alternative.
* It will impact the upgrade/degrade and data model.
* Keep implement consistance with similar existed feature.
(for example: os-update_readonly_flag action)

Data model impact
-----------------

None

REST API impact
---------------

Available value for discard is "true" or "false". (default: false)
Add a new action for the extension "VolumeActions".

For example::
POST /v1/{tenant_id}/volumes/{volume_id}/action
{
"os-update_discard_flag": {"protected": true}
}

Security impact
---------------

None

Notifications impact
--------------------

None

Other end user impact
---------------------

None

Performance Impact
------------------

None


Other deployer impact
---------------------

None

Developer impact
----------------

None


Implementation
==============

Assignee(s)
-----------

Primary assignee:
  boh.ricky(boh.ricky@gmail.com)  


Work Items
----------

'discard' property in cinder volume is implemented as an admin metadata.
* add api for set volume protected property
* add implement in cinder volume api
* add unit test

Dependencies
============

* Include specific references to specs and/or blueprints in cinder, or in other
  projects, that this one either depends on or is related to.

* If this requires functionality of another project that is not currently used
  by Cinder (such as the glance v2 API when we previously only required v1),
  document that fact.

* Does this feature require any new library dependencies or code otherwise not
  included in OpenStack? Or does it depend on a specific version of library?


Testing
=======

None

Documentation Impact
====================

Need to add the info about the new API in the document.

References
==========

1. https://review.openstack.org/#/c/85556/
