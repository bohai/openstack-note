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

* add a column to the volume table to record discard option
* modify the volume create/list/show API to suppport discard option 

Alternatives
------------

Use the admin metadata to save discard option.


Data model impact
-----------------



REST API impact
---------------

Each API method which is either added or changed should have the following

* Specification for the method

  * A description of what the method does suitable for use in
    user documentation

  * Method type (POST/PUT/GET/DELETE)

  * Normal http response code(s)

  * Expected error http response code(s)

    * A description for each possible error code should be included
      describing semantic errors which can cause it such as
      inconsistent parameters supplied to the method, or when an
      instance is not in an appropriate state for the request to
      succeed. Errors caused by syntactic problems covered by the JSON
      schema defintion do not need to be included.

  * URL for the resource

  * Parameters which can be passed via the url

  * JSON schema definition for the body data if allowed

  * JSON schema definition for the response data if any

* Example use case including typical API samples for both data supplied
  by the caller and the response

* Discuss any policy changes, and discuss what things a deployer needs to
  think about when defining their policy.

Example JSON schema definitions can be found in the Cinder tree
http://git.openstack.org/cgit/openstack/cinder/tree/cinder/api/schemas/v1.1

Note that the schema should be defined as restrictively as
possible. Parameters which are required should be marked as such and
only under exceptional circumstances should additional parameters
which are not defined in the schema be permitted (eg
additionaProperties should be False).

Reuse of existing predefined parameter types such as regexps for
passwords and user defined names is highly encouraged.

Security impact
---------------

None

Notifications impact
--------------------

None

Other end user impact
---------------------

Aside from the API, are there other ways a user will interact with this
feature?

* Does this change have an impact on python-cinderclient? What does the user
  interface there look like?

Performance Impact
------------------

Describe any potential performance impact on the system, for example
how often will new code be called, and is there a major change to the calling
pattern of existing code.

Examples of things to consider here include:

* A periodic task might look like a small addition but when considering
  large scale deployments the proposed call may in fact be performed on
  hundreds of nodes.

* Scheduler filters get called once per host for every volume being created,
  so any latency they introduce is linear with the size of the system.

* A small change in a utility function or a commonly used decorator can have a
  large impacts on performance.

* Calls which result in a database queries can have a profound impact on
  performance, especially in critical sections of code.

* Will the change include any locking, and if so what considerations are there
  on holding the lock?

Other deployer impact
---------------------

Discuss things that will affect how you deploy and configure OpenStack
that have not already been mentioned, such as:

* What config options are being added? Should they be more generic than
  proposed (for example a flag that other volume drivers might want to
  implement as well)? Are the default values ones which will work well in
  real deployments?

* Is this a change that takes immediate effect after its merged, or is it
  something that has to be explicitly enabled?

* If this change is a new binary, how would it be deployed?

* Please state anything that those doing continuous deployment, or those
  upgrading from the previous release, need to be aware of. Also describe
  any plans to deprecate configuration values or features.  For example, if we
  change the directory name that targets (LVM) are stored in, how do we handle
  any used directories created before the change landed?  Do we move them?  Do
  we have a special case in the code? Do we assume that the operator will
  recreate all the volumes in their cloud?

Developer impact
----------------

Discuss things that will affect other developers working on OpenStack,
such as:

* If the blueprint proposes a change to the driver API, discussion of how
  other volume drivers would implement the feature is required.


Implementation
==============

Assignee(s)
-----------

Primary assignee:
  boh.ricky(boh.ricky@gmail.com)  


Work Items
----------

Work items or tasks -- break the feature up into the things that need to be
done to implement it. Those parts might end up being done by different people,
but we're mostly trying to understand the timeline for implementation.


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

What is the impact on the docs team of this change? Some changes might require
donating resources to the docs team to have the documentation updated. Don't
repeat details discussed above, but please reference them here.


References
==========

Please add any useful references here. You are not required to have any
reference. Moreover, this specification should still make sense when your
references are unavailable. Examples of what you could include are:

* Links to mailing list or IRC discussions

* Links to notes from a summit session

* Links to relevant research, if appropriate

* Related specifications as appropriate (e.g. link to any vendor documentation)

* Anything else you feel it is worthwhile to refer to
