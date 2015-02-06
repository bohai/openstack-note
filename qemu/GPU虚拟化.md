### GPU虚拟化的意义   
满足以下场景：  
游戏、视频编辑、渲染、计算机辅助设计等方面对GPU的需要。

### 当前GPU虚拟化的技术  
![GPUVirtual](https://01.org/sites/default/files/xengt2.png)  
+ 软件模拟    
  比如qemu中现在模拟了vga显卡等。提供简单的显示功能。（少量寄存器、很小的显存）  
+ API转发   
  将openGL或者DirectX的API转发给host上的Graphics Driver上。  
  优点：性能佳、可以共享。  
  缺点：功能滞后。  
+ 直通设备   
  利用VT-d将显卡直通给虚拟机。  
  优点：性能佳、功能完备。    
  缺点：不能共享。  
+ 完全GPU虚拟化   
  优点：性能佳、功能完备、可以共享   
备注：虽然SR-IOV标准允许一个GPU给多个虚拟机共享使用。由于硬件的复杂性，目前但是没有GPU厂商支持。   
 

