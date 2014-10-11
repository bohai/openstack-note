### ovirt-node简介与定制方法
1. ovirt-node简介  
   1.1 ovirt-node在RHEV中的地位    
ovirt-node是Redhat ovirt项目中的一个子项目。ovirt项目的商业版本就是RHEV。ovirt-node目标是提供一个精简的面向裸金属安装的
hypervisor。ovirt-node基于fedora定制，也支持基于centos/rhel定制。  
ovirt-node在RHEV中的位置类似于ESXi在VMWARE虚拟化方案中的位置。
![ovirt_arch][1]   
![ovirt_node_arch][2]   
2. ovirt-node定制  
   3.1 ovirt-node的ISO出包方式  
ovirt-node的出包方式很简单：   
<pre><code>
a. git clone https://github.com/litevirt/ovirt-node.git       
b. cd ovirt-node      
c. sh autobuild.sh     
</code></pre>
   3.2 ovirt-node的定制方式  
ovirt-node使用livecd-tools进行ISO定制。定制脚本在recipe目录下。   
由于ovirt-node支持多个fedora/centos/rhel版本，因此目录下很多如“ ovirt17*, centos*, rhevh* "相关的ks脚本。  
ovirt-node-image.ks.in是入口脚本，将相关的install, pkg, minimizer,post脚本串起来。
<pre><code>
# @DISTRO@ Node image recipe
%include common-install.ks
%include @DISTRO@-install.ks
%include repos.ks
%packages --excludedocs --nobase
%include common-pkgs.ks
%include @DISTRO@-pkgs.ks
%end
%post
%include common-post.ks
%include @DISTRO@-post.ks
%end
%post --nochroot
%include common-nochroot.ks
%end
@IMAGE_MINIMIZER@
@MANIFESTS_INCLUDED@
</code></pre>

参考：  
http://www.ovirt.org/images/2/2f/Ovirt-node.pdf  
http://www.ibm.com/developerworks/cn/linux/l-cn-ovirt/  
http://www.ibm.com/developerworks/cn/linux/1306_qiaoly_ovirtnode/index.html  

[1]: http://img.ddvip.com/2012/0925/201209250321423983.jpg
[2]: http://www.dedecms.com/uploads/allimg/c121015/13502F1GF10-602632.jpg
