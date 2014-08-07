diff --git a/nova/tests/virt/libvirt/test_config.py b/nova/tests/virt/libvirt/test_config.py
index e0363ed..0fef2da 100644
--- a/nova/tests/virt/libvirt/test_config.py
+++ b/nova/tests/virt/libvirt/test_config.py
@@ -463,6 +463,44 @@ class LibvirtConfigGuestDiskTest(LibvirtConfigBaseTest):
         self.assertEqual(obj.source_type, 'file')
         self.assertEqual(obj.serial, '7a97c4a3-6f59-41d4-bf47-191d7f97f8e9')

+    def test_config_file_discard(self):
+        obj = config.LibvirtConfigGuestDisk()
+        obj.driver_name = "qemu"
+        obj.driver_format = "qcow2"
+        obj.driver_cache = "none"
+        obj.driver_discard = "unmap"
+        obj.source_type = "file"
+        obj.source_path = "/tmp/hello.qcow2"
+        obj.target_dev = "/dev/hda"
+        obj.target_bus = "ide"
+        obj.serial = "7a97c4a3-6f59-41d4-bf47-191d7f97f8e9"
+
+        xml = obj.to_xml()
+        self.assertXmlEqual(xml, """
+            <disk type="file" device="disk">
+              <driver name="qemu" type="qcow2" cache="none" discard="unmap"/>
+              <source file="/tmp/hello.qcow2"/>
+              <target bus="ide" dev="/dev/hda"/>
+              <serial>7a97c4a3-6f59-41d4-bf47-191d7f97f8e9</serial>
+            </disk>""")
+
+    def test_config_file_discard_parse(self):
+        xml = """
+            <disk type="file" device="disk">
+              <driver name="qemu" type="qcow2" cache="none" discard="unmap"/>
+              <source file="/tmp/hello.qcow2"/>
+              <target bus="ide" dev="/dev/hda"/>
+              <serial>7a97c4a3-6f59-41d4-bf47-191d7f97f8e9</serial>
+            </disk>"""
+        xmldoc = etree.fromstring(xml)
+
+        obj = config.LibvirtConfigGuestDisk()
+        obj.parse_dom(xmldoc)
+
+        self.assertEqual(obj.driver_discard, 'unmap')
+
+        pass
+
     def test_config_block(self):
         obj = config.LibvirtConfigGuestDisk()
         obj.source_type = "block"
diff --git a/nova/tests/virt/libvirt/test_utils.py b/nova/tests/virt/libvirt/test_utils.py
index 827b2cf..68dc495 100644
--- a/nova/tests/virt/libvirt/test_utils.py
+++ b/nova/tests/virt/libvirt/test_utils.py
@@ -47,6 +47,11 @@ blah BLAH: bb
         disk_type = libvirt_utils.get_disk_type(path)
         self.assertEqual(disk_type, 'raw')

+    def test_get_hw_disk_discard(self):
+        self.assertEqual('unmap', libvirt_utils.get_hw_disk_discard("unmap"))
+        self.assertEqual('ignore', libvirt_utils.get_hw_disk_discard("ignore"))
+        self.assertIsNone(libvirt_utils.get_hw_disk_discard("fake"))
+
     def test_list_rbd_volumes(self):
         conf = '/etc/ceph/fake_ceph.conf'
         pool = 'fake_pool'
@@ -339,3 +344,5 @@ ID        TAG                 VM SIZE                DATE       VM CLOCK
         self.assertEqual(67108864, image_info.virtual_size)
         self.assertEqual(98304, image_info.disk_size)
         self.assertEqual(3, len(image_info.snapshots))
+
+
diff --git a/nova/virt/libvirt/config.py b/nova/virt/libvirt/config.py
index 7ff03ff..0e3e54f 100644
--- a/nova/virt/libvirt/config.py
+++ b/nova/virt/libvirt/config.py
@@ -481,6 +481,7 @@ class LibvirtConfigGuestDisk(LibvirtConfigGuestDevice):
         self.driver_name = None
         self.driver_format = None
         self.driver_cache = None
+        self.driver_discard = None
         self.source_path = None
         self.source_protocol = None
         self.source_name = None
@@ -511,7 +512,8 @@ class LibvirtConfigGuestDisk(LibvirtConfigGuestDevice):
         dev.set("device", self.source_device)
         if (self.driver_name is not None or
             self.driver_format is not None or
-                self.driver_cache is not None):
+            self.driver_cache is not None or
+                self.driver_discard is not None):
             drv = etree.Element("driver")
             if self.driver_name is not None:
                 drv.set("name", self.driver_name)
@@ -519,6 +521,8 @@ class LibvirtConfigGuestDisk(LibvirtConfigGuestDevice):
                 drv.set("type", self.driver_format)
             if self.driver_cache is not None:
                 drv.set("cache", self.driver_cache)
+            if self.driver_discard is not None:
+                drv.set("discard", self.driver_discard)
             dev.append(drv)

         if self.source_type == "file":
@@ -613,6 +617,7 @@ class LibvirtConfigGuestDisk(LibvirtConfigGuestDevice):
                 self.driver_name = c.get('name')
                 self.driver_format = c.get('type')
                 self.driver_cache = c.get('cache')
+                self.driver_discard = c.get('discard')
             elif c.tag == 'source':
                 if self.source_type == 'file':
                     self.source_path = c.get('file')
diff --git a/nova/virt/libvirt/imagebackend.py b/nova/virt/libvirt/imagebackend.py
index 4caf9e0..3e16b98 100644
--- a/nova/virt/libvirt/imagebackend.py
+++ b/nova/virt/libvirt/imagebackend.py
@@ -70,6 +70,11 @@ __imagebackend_opts = [
     cfg.StrOpt('images_rbd_ceph_conf',
                default='',  # default determined by librados
                help='Path to the ceph configuration file to use'),
+    cfg.StrOpt('hw_disk_discard',
+               default=None,
+               help='Discard option for nova managed disks (valid options '
+                    'are: ignore, unmap). Need Libvirt(1.0.6) Qemu1.5 '
+                    '(raw format) Qemu1.6(qcow2 format'),
         ]

 CONF = cfg.CONF
@@ -80,6 +85,8 @@ CONF.import_opt('preallocate_images', 'nova.virt.driver')
 LOG = logging.getLogger(__name__)


+
+
 @six.add_metaclass(abc.ABCMeta)
 class Image(object):

@@ -92,6 +99,8 @@ class Image(object):
         """
         self.source_type = source_type
         self.driver_format = driver_format
+        self.discard_mode = libvirt_utils.get_hw_disk_discard(
+                CONF.libvirt.hw_disk_discard)
         self.is_block_dev = is_block_dev
         self.preallocate = False

@@ -134,6 +143,7 @@ class Image(object):
         info.target_bus = disk_bus
         info.target_dev = disk_dev
         info.driver_cache = cache_mode
+        info.driver_discard = self.discard_mode
         info.driver_format = self.driver_format
         driver_name = libvirt_utils.pick_disk_driver_name(hypervisor_version,
                                                           self.is_block_dev)
@@ -549,6 +559,8 @@ class Rbd(Image):
                                  ' images_rbd_pool'
                                  ' flag to use rbd images.'))
         self.pool = CONF.libvirt.images_rbd_pool
+        self.discard_mode = libvirt_utils.get_hw_disk_discard(
+                CONF.libvirt.hw_disk_discard)
         self.ceph_conf = ascii_str(CONF.libvirt.images_rbd_ceph_conf)
         self.rbd_user = ascii_str(CONF.libvirt.rbd_user)
         self.rbd = kwargs.get('rbd', rbd)
@@ -622,6 +634,7 @@ class Rbd(Image):
         info.device_type = device_type
         info.driver_format = 'raw'
         info.driver_cache = cache_mode
+        info.driver_discard = self.discard_mode
         info.target_bus = disk_bus
         info.target_dev = disk_dev
         info.source_type = 'network'
diff --git a/nova/virt/libvirt/utils.py b/nova/virt/libvirt/utils.py
index af0cd40..02a5cba 100644
--- a/nova/virt/libvirt/utils.py
+++ b/nova/virt/libvirt/utils.py
@@ -28,6 +28,7 @@ from oslo.config import cfg
 from nova.i18n import _
 from nova.i18n import _LI
 from nova.i18n import _LW
+from nova.i18n import _LE
 from nova.openstack.common import log as logging
 from nova.openstack.common import processutils
 from nova import utils
@@ -535,3 +536,13 @@ def is_mounted(mount_path, source=None):
         if exc.errno == errno.ENOENT:
             LOG.info(_LI("findmnt tool is not installed"))
         return False
+
+
+def get_hw_disk_discard(hw_disk_discard):
+    """Check valid and get hw_disk_discard value from Conf.
+    """
+    if hw_disk_discard not in ('unmap', 'ignore'):
+        LOG.error(_LE("ignoring unrecognized hw_disk_discard='%s' value"),
+                  hw_disk_discard)
+        return None
+    return hw_disk_discard
